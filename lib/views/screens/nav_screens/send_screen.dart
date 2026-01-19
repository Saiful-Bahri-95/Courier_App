import 'package:flutter/material.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/step_receiver_modern.dart';
import 'package:store_app/views/screens/nav_screens/widgets/send_form/step_sender_modern.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 12, 210, 255), Color(0xFF090979)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                step == 0 ? 'Send Receipt' : 'Receipt Detail',
                style: const TextStyle(
                  color: Color(0xFF030F2F),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: step == 0
                            ? const StepSenderModern()
                            : const StepReceiverModern(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (step > 0)
                            TextButton(
                              onPressed: () => setState(() => step--),
                              child: const Text('Back'),
                            ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              if (step == 0) {
                                setState(() => step = 1);
                              } else {
                                // SUBMIT ACTION
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: Color.fromARGB(
                                255,
                                51,
                                121,
                                242,
                              ),
                              elevation: 6,
                              shadowColor: Colors.black,
                            ),

                            child: Text(
                              step == 0 ? 'Next' : 'Submit',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
