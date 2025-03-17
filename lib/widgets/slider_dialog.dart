import 'package:flutter/material.dart';
import 'package:questionnaires/configs/text_scaler.dart';
import 'package:provider/provider.dart';

class ScalingWrapper extends StatefulWidget {
  final Widget child;
  ScalingWrapper({required this.child});
  State<ScalingWrapper> createState() => _ScalingWrapperState();
}

class _ScalingWrapperState extends State<ScalingWrapper> {
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    double scaling = context.watch<TextScaleProvider>().scale;
    return MediaQuery(
      data: data.copyWith(textScaleFactor: scaling),
      child: this.widget.child,
    );
  }
}

class SliderDialog extends StatefulWidget {
  const SliderDialog({Key? key}) : super(key: key);

  @override
  State<SliderDialog> createState() => _SliderDialogState();
}

class _SliderDialogState extends State<SliderDialog> {
  double _currentSliderValue = 100;

  Widget build(BuildContext context) {
    return ScalingWrapper(
      child: SimpleDialog(
        title: Text('Textgröße einstellen:'),
        children: <Widget>[
          Slider(
            min: 80,
            max: 160,
            divisions: 8,
            thumbColor: Theme.of(context).colorScheme.primary,
            activeColor: Theme.of(context).colorScheme.primary,
            value: _currentSliderValue,
            label: _currentSliderValue.round().toString() + "%",
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
                double v = value / 100;
                context.read<TextScaleProvider>().setScale(v);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Speichern"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
