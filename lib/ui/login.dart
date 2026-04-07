import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
	const LoginPage({super.key});

	@override
	State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
	bool _isCustomer = true;
	bool _obscurePassword = true;
	bool _staySignedIn = false;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Container(
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [Color(0xFFCEE2EF), Color(0xFFC4D0E1)],
					),
				),
				child: SafeArea(
					child: SingleChildScrollView(
						child: Padding(
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
							child: Column(
								children: [
									const SizedBox(height: 10),
									_buildBrand(),
									const SizedBox(height: 28),
									_buildLoginPanel(),
									const SizedBox(height: 26),
									_buildFooterLinks(),
									const SizedBox(height: 8),
								],
							),
						),
					),
				),
			),
		);
	}

	Widget _buildBrand() {
		return Column(
			children: const [
				CircleAvatar(
					radius: 42,
					backgroundColor: Color(0xFF003A93),
					child: Icon(Icons.water_drop_rounded, color: Colors.white, size: 44),
				),
				SizedBox(height: 20),
				Text(
					'PEYDAR',
					style: TextStyle(
						fontSize: 64 * 0.66,
						fontWeight: FontWeight.w700,
						color: Color(0xFF003A93),
						letterSpacing: -0.6,
					),
				),
				SizedBox(height: 6),
				Text(
					'PURITY IN EVERY DROP',
					style: TextStyle(
						fontSize: 16,
						fontWeight: FontWeight.w500,
						color: Color(0xFF2D3342),
						letterSpacing: 2,
					),
				),
			],
		);
	}

	Widget _buildLoginPanel() {
		return Container(
			width: double.infinity,
			padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
			decoration: BoxDecoration(
				color: const Color(0xFFF1F3F5),
				borderRadius: BorderRadius.circular(34),
				boxShadow: const [
					BoxShadow(
						color: Color(0x1A1C2737),
						blurRadius: 24,
						offset: Offset(0, 12),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text(
						'Welcome Back',
						style: TextStyle(
							fontSize: 50 * 0.66,
							fontWeight: FontWeight.w700,
							color: Color(0xFF10141C),
						),
					),
					const SizedBox(height: 22),
					_buildRoleSelector(),
					const SizedBox(height: 30),
					const Text(
						'EMAIL ADDRESS',
						style: TextStyle(
							fontSize: 15,
							fontWeight: FontWeight.w700,
							color: Color(0xFF394053),
							letterSpacing: 1.8,
						),
					),
					const SizedBox(height: 12),
					_InputContainer(
						child: Row(
							children: const [
								Icon(Icons.mail_rounded, color: Color(0xFF6E7483), size: 28),
								SizedBox(width: 14),
								Expanded(
									child: TextField(
										decoration: InputDecoration(
											hintText: 'name@example.com',
											border: InputBorder.none,
											hintStyle: TextStyle(
												color: Color(0xFF727989),
												fontSize: 28 * 0.66,
											),
										),
										keyboardType: TextInputType.emailAddress,
									),
								),
							],
						),
					),
					const SizedBox(height: 26),
					Row(
						children: const [
							Expanded(
								child: Text(
									'PASSWORD',
									style: TextStyle(
										fontSize: 15,
										fontWeight: FontWeight.w700,
										color: Color(0xFF394053),
										letterSpacing: 1.8,
									),
								),
							),
							Text(
								'Forgot?',
								style: TextStyle(
									color: Color(0xFF00328B),
									fontSize: 35 * 0.42,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
					const SizedBox(height: 12),
					_InputContainer(
						child: Row(
							children: [
								const Icon(Icons.lock_rounded, color: Color(0xFF6E7483), size: 30),
								const SizedBox(width: 14),
								Expanded(
									child: TextField(
										obscureText: _obscurePassword,
										decoration: const InputDecoration(
											hintText: '••••••••',
											border: InputBorder.none,
											hintStyle: TextStyle(
												color: Color(0xFF727989),
												fontSize: 30 * 0.66,
												letterSpacing: 2,
											),
										),
									),
								),
								IconButton(
									splashRadius: 22,
									onPressed: () {
										setState(() {
											_obscurePassword = !_obscurePassword;
										});
									},
									icon: Icon(
										_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
										color: const Color(0xFF727989),
										size: 33,
									),
								),
							],
						),
					),
					const SizedBox(height: 24),
					Row(
						children: [
							SizedBox(
								height: 30,
								width: 30,
								child: Checkbox(
									value: _staySignedIn,
									onChanged: (value) {
										setState(() {
											_staySignedIn = value ?? false;
										});
									},
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(6),
									),
									side: const BorderSide(color: Color(0xFFAFB6C7), width: 2),
								),
							),
							const SizedBox(width: 14),
							const Text(
								'Stay signed in for 30 days',
								style: TextStyle(
									color: Color(0xFF2E3446),
									fontSize: 38 * 0.56,
									fontWeight: FontWeight.w500,
								),
							),
						],
					),
					const SizedBox(height: 30),
					SizedBox(
						width: double.infinity,
						height: 92 * 0.66,
						child: ElevatedButton(
							style: ElevatedButton.styleFrom(
								elevation: 2,
								backgroundColor: const Color(0xFF073F9E),
								foregroundColor: Colors.white,
								shape: RoundedRectangleBorder(
									borderRadius: BorderRadius.circular(100),
								),
							),
							onPressed: () {},
							child: const Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Text(
										'Sign In to Account',
										style: TextStyle(fontSize: 22 * 0.66, fontWeight: FontWeight.w700),
									),
									SizedBox(width: 14),
									Icon(Icons.arrow_forward, size: 35 * 0.66),
								],
							),
						),
					),
					const SizedBox(height: 26),
					Container(height: 1.6, color: const Color(0xFFD2D7DF)),
					const SizedBox(height: 24),
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: const [
							Text(
								'Don\'t have an account yet? ',
								style: TextStyle(
									color: Color(0xFF2E3446),
									fontSize: 20 * 0.66,
								),
							),
							Text(
								'Create Account',
								style: TextStyle(
									color: Color(0xFF00328B),
									fontSize: 20 * 0.66,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
				],
			),
		);
	}

	Widget _buildRoleSelector() {
		return Container(
			padding: const EdgeInsets.all(8),
			decoration: BoxDecoration(
				color: const Color(0xFFE1E4E9),
				borderRadius: BorderRadius.circular(40),
			),
			child: Row(
				children: [
					Expanded(
						child: _RoleButton(
							text: 'Customer',
							active: _isCustomer,
							onTap: () {
								setState(() {
									_isCustomer = true;
								});
							},
						),
					),
					Expanded(
						child: _RoleButton(
							text: 'Administrator',
							active: !_isCustomer,
							onTap: () {
								setState(() {
									_isCustomer = false;
								});
							},
						),
					),
				],
			),
		);
	}

	Widget _buildFooterLinks() {
		return const Padding(
			padding: EdgeInsets.only(bottom: 6),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(
						'Privacy Policy',
						style: TextStyle(color: Color(0xFF7D8596), fontSize: 34 * 0.5),
					),
					SizedBox(width: 20),
					Text('•', style: TextStyle(color: Color(0xFFB0B7C6), fontSize: 16)),
					SizedBox(width: 20),
					Text(
						'Terms of Service',
						style: TextStyle(color: Color(0xFF7D8596), fontSize: 34 * 0.5),
					),
					SizedBox(width: 20),
					Text('•', style: TextStyle(color: Color(0xFFB0B7C6), fontSize: 16)),
					SizedBox(width: 20),
					Text(
						'Support',
						style: TextStyle(color: Color(0xFF7D8596), fontSize: 34 * 0.5),
					),
				],
			),
		);
	}
}

class _RoleButton extends StatelessWidget {
	const _RoleButton({required this.text, required this.active, required this.onTap});

	final String text;
	final bool active;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 200),
				padding: const EdgeInsets.symmetric(vertical: 12),
				decoration: BoxDecoration(
					color: active ? const Color(0xFFF6F7F9) : Colors.transparent,
					borderRadius: BorderRadius.circular(30),
					boxShadow: active
							? const [
									BoxShadow(
										color: Color(0x160E1B2D),
										blurRadius: 12,
										offset: Offset(0, 4),
									),
								]
							: null,
				),
				child: Center(
					child: Text(
						text,
						style: TextStyle(
							fontSize: 20 * 0.66,
							fontWeight: FontWeight.w700,
							color: active ? const Color(0xFF02358E) : const Color(0xFF404757),
						),
					),
				),
			),
		);
	}
}

class _InputContainer extends StatelessWidget {
	const _InputContainer({required this.child});

	final Widget child;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 16),
			decoration: BoxDecoration(
				color: const Color(0xFFD8DBE0),
				borderRadius: BorderRadius.circular(18),
			),
			child: child,
		);
	}
}