// send-order-notification — Edge Function for Supabase
// Trigger: Database webhook (INSERT on pedidos)
// Action: Sends push notification to ALL admins via Firebase Cloud Messaging
//
// Setup:
//   Option A (simple): Firebase Console > Cloud Messaging > Server Key
//     supabase secrets set FCM_SERVER_KEY 'AAAA...'
//
//   Option B (service account): Firebase Console > Project Settings > Service Accounts
//     supabase secrets set FIREBASE_SERVICE_ACCOUNT '{"type":"service_account",...}'

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface WebhookPayload {
  type: 'INSERT';
  table: string;
  schema: string;
  record: {
    id: number;
    usuario_id: number;
    direccion_entrega: string;
    telefono_contacto: string;
    estado: string;
    created_at: string;
    [key: string]: unknown;
  };
}

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const pedido = payload.record;

    // 1. Get FCM tokens from all admins
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { data: admins, error: adminError } = await supabase
      .from('usuario')
      .select('id, nombre, apellido, fcm_token')
      .eq('tipo_usuario', 'administrador')
      .not('fcm_token', 'is', null);

    if (adminError) {
      return new Response(JSON.stringify({ error: adminError.message }), {
        status: 500,
      });
    }

    if (!admins || admins.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No admin tokens found' }),
        { status: 200 },
      );
    }

    // 2. Get customer name
    const { data: cliente } = await supabase
      .from('usuario')
      .select('nombre, apellido')
      .eq('id', pedido.usuario_id)
      .single();

    const clienteNombre = cliente
      ? (cliente.nombre || '') + ' ' + (cliente.apellido || '')
      : 'Un cliente';

    // 3. Send push to each admin
    const tokens = admins
      .map((a) => a.fcm_token)
      .filter((t): t is string => t != null);

    let enviados = 0;
    const errores: string[] = [];

    for (const token of tokens) {
      try {
        await enviarPushFCM(token, {
          title: 'Nuevo Pedido',
          body: clienteNombre.trim() + ' realizo un pedido #' + pedido.id,
          data: {
            pedido_id: pedido.id.toString(),
            type: 'new_order',
          },
        });
        enviados++;
      } catch (e) {
        errores.push(String(e));
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        enviados,
        total: tokens.length,
        errores: errores.length > 0 ? errores : undefined,
      }),
      { status: 200 },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
    });
  }
});

// ─── Send push via FCM ───────────────────────────────────────────────────

async function enviarPushFCM(
  token: string,
  notification: { title: string; body: string; data?: Record<string, string> },
) {
  // Prefer FCM_SERVER_KEY (simple), fall back to FIREBASE_SERVICE_ACCOUNT
  const serverKey = Deno.env.get('FCM_SERVER_KEY');
  const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');

  if (serverKey) {
    // Option A: Legacy API with Server Key
    await sendViaLegacyApi(token, notification, serverKey);
  } else if (serviceAccountJson) {
    // Option B: HTTP v1 API with Service Account
    await sendViaV1Api(token, notification, serviceAccountJson);
  } else {
    throw new Error(
      'No FCM credential configured. Set FCM_SERVER_KEY or FIREBASE_SERVICE_ACCOUNT as Supabase secret.',
    );
  }
}

// ─── Option A: FCM Legacy API (Server Key) ─────────────────────────────

async function sendViaLegacyApi(
  token: string,
  notification: { title: string; body: string; data?: Record<string, string> },
  serverKey: string,
) {
  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'key=' + serverKey,
    },
    body: JSON.stringify({
      to: token,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: notification.data || {},
      android: {
        priority: 'high',
        notification: {
          channelId: 'peydar_orders',
          priority: 'high',
        },
      },
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error('FCM legacy error ' + response.status + ': ' + text);
  }
}

// ─── Option B: FCM HTTP v1 API (Service Account OAuth2) ────────────────

async function sendViaV1Api(
  token: string,
  notification: { title: string; body: string; data?: Record<string, string> },
  serviceAccountJson: string,
) {
  const sa = JSON.parse(serviceAccountJson);
  if (!sa.client_email) {
    throw new Error('Invalid FIREBASE_SERVICE_ACCOUNT JSON');
  }

  const accessToken = await getAccessToken(sa);

  const response = await fetch(
    'https://fcm.googleapis.com/v1/projects/' + sa.project_id + '/messages:send',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + accessToken,
      },
      body: JSON.stringify({
        message: {
          token,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data,
          android: {
            priority: 'high',
            notification: {
              channelId: 'peydar_orders',
              priority: 'high',
            },
          },
        },
      }),
    },
  );

  if (!response.ok) {
    const text = await response.text();
    throw new Error('FCM v1 error ' + response.status + ': ' + text);
  }
}

// ─── OAuth2: JWT -> access token ──────────────────────────────────────

async function getAccessToken(sa: {
  client_email: string;
  private_key: string;
  private_key_id: string;
  token_uri?: string;
}): Promise<string> {
  const tokenUri = sa.token_uri || 'https://oauth2.googleapis.com/token';

  // Use Web Crypto API (Deno compatible)
  const header = { alg: 'RS256', typ: 'JWT', kid: sa.private_key_id };
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: tokenUri,
    exp: now + 3600,
    iat: now,
  };

  const b64url = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const headerB64 = b64url(header);
  const claimsB64 = b64url(claims);
  const toSign = headerB64 + '.' + claimsB64;

  const keyData = pemToBinary(sa.private_key);
  const key = await crypto.subtle.importKey(
    'pkcs8', keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );
  const sig = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' }, key,
    new TextEncoder().encode(toSign),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const jwt = toSign + '.' + sigB64;

  const res = await fetch(tokenUri, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  });

  if (!res.ok) throw new Error('OAuth error ' + res.status + ': ' + await res.text());

  const data = await res.json();
  return data.access_token as string;
}

function pemToBinary(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN [\w\s]+-----/g, '')
    .replace(/-----END [\w\s]+-----/g, '')
    .replace(/\s/g, '');
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}
