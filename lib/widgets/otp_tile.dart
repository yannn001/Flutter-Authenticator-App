import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_authenticator/utils/otp_utils.dart';

class OtpTile extends StatefulWidget {
  final String account, issuer, secret;
  final VoidCallback onDelete;
  final Future<bool> Function() confirmDelete;

  const OtpTile({
    super.key,
    required this.account,
    required this.issuer,
    required this.secret,
    required this.onDelete,
    required this.confirmDelete,
  });

  @override
  State<OtpTile> createState() => _OtpTileState();
}

class _OtpTileState extends State<OtpTile> with SingleTickerProviderStateMixin {
  late String otp;
  late final ticker;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
        _generateOtp();
      }
    });
    _generateOtp();
    _controller.forward();
  }

  void _generateOtp() {
    otp = generateTOTP(widget.secret);
    setState(() {});
  }

  void _copyOtpToClipboard() {
    Clipboard.setData(ClipboardData(text: otp));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP copied to clipboard')));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.account + widget.issuer),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await widget.confirmDelete();
      },
      onDismissed: (direction) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: const Color.fromARGB(255, 15, 15, 15),
        child: const Icon(
          Icons.delete_forever_rounded,
          color: Colors.red,
          size: 40,
        ),
      ),
      child: GestureDetector(
        onTap: _copyOtpToClipboard,
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color.fromARGB(255, 22, 22, 22),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: TextAvatar(
                            text: widget.issuer,
                            textColor: Colors.black,
                            numberLetters: 2,
                            size: 50,
                            fontSize: 24,
                            upperCase: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.issuer,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              widget.account,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildOtpDigits(otp),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 18,
                right: 18,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 6,
                        backgroundColor: Colors.blue,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color.fromARGB(255, 26, 25, 25),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOtpDigits(String otp) {
    return otp.split('').map((digit) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 9),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 17, 17, 17),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          digit,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      );
    }).toList();
  }
}
