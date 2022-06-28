import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({Key? key, required this.labelText, required this.onSaved}) : super(key: key);

  final String? labelText;
  final FormFieldSetter<String>? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: labelText),
      validator: (value) => value!.isNotEmpty ? null : "$labelText kan niet leeg zijn",
      onSaved: onSaved,
    );
  }

  void test(){
    print(labelText);
  }
}
