import 'package:flutter/material.dart';
import '../configs/styles.dart';
import 'custom_rect_tween.dart';
import '../routes/hero_dialog_route.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

/// {@template info_button}
/// Button to show info.
///
/// Opens a [HeroDialogRoute] of [_AddTodoPopupCard].
///
/// Uses a [Hero] with tag [_heroAddTodo].
/// {@endtemplate}
class InfoButton extends StatelessWidget {
  final String infoText;
  final Map<String, String> infoURLs;

  /// {@macro info_button}
  const InfoButton({Key? key, required this.infoText, required this.infoURLs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return _InfoPopupCard(
                infoText: this.infoText, infoURLs: this.infoURLs);
          }));
        },
        child: Hero(
          tag: _heroInfo,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: AppColors.accentColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: const Icon(
              Icons.info,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}

/// Tag-value used for the add todo popup button.
const String _heroInfo = 'info-hero';

/// {@template add_todo_popup_card}
/// Popup card to show info. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_infoTodo].
/// {@endtemplate}
class _InfoPopupCard extends StatelessWidget {
  /// {@macro add_todo_popup_card}
  final String infoText;
  final Map<String, String> infoURLs;

  const _InfoPopupCard(
      {Key? key, required this.infoText, required this.infoURLs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Hero(
          tag: _heroInfo,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: Material(
            color: AppColors.accentColor,
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    this.createInfoWidget(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createInfoWidget() {
    TextSpan textField = new TextSpan(text: this.infoText, children: []);
    RichText widget =
        new RichText(text: TextSpan(text: "", children: [textField]));

    if (this.infoURLs != null)
      textField.children!.add(new TextSpan(
          text:
              "\n\nWeitere Infos können unter folgenden Links gefunden werden : \n"));
    this.infoURLs.entries.forEach((element) {
      textField.children!.add(new TextSpan(
        text: "\n" + element.key + "\n",
        style: new TextStyle(color: Colors.blue),
        recognizer: new TapGestureRecognizer()
          ..onTap = () {
            launch(element.value);
          },
      ));
    });

    return widget;
  }
}
