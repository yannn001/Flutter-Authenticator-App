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
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildIssuerIcon(widget.issuer),
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

  Widget _buildIssuerIcon(String issuer) {
    final iconUrl = _getIssuerIconUrl(issuer);
    if (iconUrl != null) {
      return Image.network(
        iconUrl,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
        errorBuilder: (context, error, stackTrace) {
          return TextAvatar(
            text: issuer,
            textColor: Colors.black,
            numberLetters: 2,
            size: 50,
            fontSize: 24,
            upperCase: true,
          );
        },
      );
    } else {
      return TextAvatar(
        text: issuer,
        textColor: Colors.black,
        numberLetters: 2,
        size: 50,
        fontSize: 24,
        upperCase: true,
      );
    }
  }

  String? _getIssuerIconUrl(String issuer) {
    final icons = {
      'Google': 'https://img.icons8.com/color/100/google-logo.png',
      'Facebook': 'https://img.icons8.com/color/100/facebook.png',
      'Twitter': 'https://img.icons8.com/ios-filled/100/twitterx--v1.png',
      'GitHub': 'https://img.icons8.com/ios-filled/100/github.png',
      'LinkedIn': 'https://img.icons8.com/fluency/150/linkedin.png',
      'Instagram': 'https://img.icons8.com/color/100/instagram-new--v1.png',
      'Microsoft': 'https://img.icons8.com/color/100/microsoft.png',
      'Dropbox': 'https://img.icons8.com/color/100/dropbox.png',
      'Slack': 'https://img.icons8.com/color/100/slack-new.png',
      'Amazon': 'https://img.icons8.com/color/100/amazon.png',
      'Twitch': 'https://img.icons8.com/color/100/twitch.png',
      'Snapchat': 'https://img.icons8.com/color/100/snapchat.png',
      'WhatsApp': 'https://img.icons8.com/color/100/whatsapp.png',
      'PayPal': 'https://img.icons8.com/color/100/paypal.png',
      'TikTok': 'https://img.icons8.com/color/50/tiktok.png',
      'Netflix': 'https://img.icons8.com/color/50/netflix.png',
      'Spotify': 'https://img.icons8.com/color/50/spotify.png',
      'Discord': 'https://img.icons8.com/color/50/discord-new-logo.png',
      'Reddit': 'https://img.icons8.com/color/50/reddit.png',
      'Steam': 'https://img.icons8.com/color/50/steam.png',
      'Epic Games': 'https://img.icons8.com/color/50/epic-games.png',
      'Origin': 'https://img.icons8.com/color/50/origin.png',
      'Uplay': 'https://img.icons8.com/color/50/uplay.png',
      'Battle.net': 'https://img.icons8.com/color/50/battle-net.png',
      'PlayStation': 'https://img.icons8.com/color/50/playstation.png',
      'Xbox': 'https://img.icons8.com/color/50/xbox.png',
      'Nintendo': 'https://img.icons8.com/color/50/nintendo.png',
      'Apple': 'https://img.icons8.com/ios-filled/100/mac-os.png',
      'Samsung': 'https://img.icons8.com/color/50/samsung.png',
      'Huawei': 'https://img.icons8.com/color/50/huawei.png',
      'Sony': 'https://img.icons8.com/color/50/sony.png',
    };

    return icons[issuer];
  }
}
