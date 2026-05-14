import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:apppeydar/services/maps_service.dart';

class MapaPickerScreen extends StatefulWidget {
  const MapaPickerScreen({super.key});

  @override
  State<MapaPickerScreen> createState() => _MapaPickerScreenState();
}

class _MapaPickerScreenState extends State<MapaPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Default location: Piura, Peru
  static const LatLng _defaultLocation = LatLng(-5.1944, -80.6328);
  static const double _defaultZoom = 17.0;

  LatLng _selectedPosition = _defaultLocation;
  String _selectedAddress = 'Seleccioná una ubicación en el mapa';

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceSearch;
  Timer? _debounceReverseGeocode;
  bool _reverseGeocodeInProgress = false;

  @override
  void initState() {
    super.initState();
    // Reverse geocode the initial position after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocodePosition(_defaultLocation);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceSearch?.cancel();
    _debounceReverseGeocode?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // --- Search ---

  void _onSearchChanged(String query) {
    _debounceSearch?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounceSearch = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      final results = await MapsService.searchPlaces(query);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    });
  }

  Future<void> _onSelectSearchResult(Map<String, dynamic> result) async {
    final latStr = result['lat'] as String?;
    final lonStr = result['lon'] as String?;
    if (latStr == null || lonStr == null) return;

    final lat = double.tryParse(latStr);
    final lon = double.tryParse(lonStr);
    if (lat == null || lon == null) return;

    final address = result['display_name'] as String? ?? _searchController.text;

    _searchFocusNode.unfocus();
    setState(() {
      _searchResults = [];
      _searchController.text = address;
      _selectedPosition = LatLng(lat, lon);
      _selectedAddress = address;
    });

    _mapController.move(LatLng(lat, lon), _defaultZoom);
  }

  // --- Map position changes ---

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _debounceReverseGeocode?.cancel();
    _debounceReverseGeocode = Timer(const Duration(milliseconds: 500), () {
      _reverseGeocodePosition(camera.center);
    });
  }

  Future<void> _reverseGeocodePosition(LatLng position) async {
    if (_reverseGeocodeInProgress) return;
    _reverseGeocodeInProgress = true;

    setState(() {
      _selectedPosition = position;
    });

    final address =
        await MapsService.reverseGeocode(position.latitude, position.longitude);

    if (!mounted) {
      _reverseGeocodeInProgress = false;
      return;
    }

    if (address != null) {
      setState(() => _selectedAddress = address);
    }
    _reverseGeocodeInProgress = false;
  }

  // --- Confirm ---

  void _confirmarDireccion() {
    Navigator.pop(context, {
      'direccion': _selectedAddress,
      'latitud': _selectedPosition.latitude,
      'longitud': _selectedPosition.longitude,
    });
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    final searchOverlayVisible = _searchResults.isNotEmpty && _searchFocusNode.hasFocus;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003DA5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Seleccionar dirección',
          style: TextStyle(
            color: Color(0xFF002855),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              _buildSearchBar(),
              // Map with centered pin
              Expanded(child: _buildMapWithPin()),
              // Bottom bar
              _buildBottomBar(),
            ],
          ),
          // Search results overlay
          if (searchOverlayVisible) _buildSearchOverlay(),
        ],
      ),

    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar dirección...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF003DA5)),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF003DA5)),
                  ),
                )
              : (_searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null),
          filled: true,
          fillColor: const Color(0xFFF1F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMapWithPin() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultLocation,
            initialZoom: _defaultZoom,
            onPositionChanged: _onPositionChanged,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.apppeydar.app',
            ),
          ],
        ),
        // Centered pin — stays fixed on screen while map moves underneath
        const Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFF003DA5),
                    size: 40,
                  ),
                  // Nudge up to account for the pin's pointy end being at the center
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return Positioned(
      top: 56, // below search bar
      left: 16,
      right: 16,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final result = _searchResults[index];
            final displayName = result['display_name'] as String? ?? '';
            // Split display_name by comma: first part = main, rest = secondary
            final parts = displayName.split(',');
            final mainText = parts.first.trim();
            final secondaryText = parts.length > 1
                ? parts.sublist(1).join(',').trim()
                : '';

            return ListTile(
              dense: true,
              leading: const Icon(Icons.location_on_outlined, color: Color(0xFF003DA5), size: 22),
              title: Text(
                mainText,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: secondaryText.isNotEmpty
                  ? Text(
                      secondaryText,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () => _onSelectSearchResult(result),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF003DA5), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedAddress,
                    style: const TextStyle(
                      color: Color(0xFF002855),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmarDireccion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003DA5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Confirmar dirección',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
