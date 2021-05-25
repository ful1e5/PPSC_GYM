import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'package:ppscgym/services/database/handler.dart';
import 'package:ppscgym/services/database/models.dart';

import 'package:ppscgym/utils.dart';
import 'package:ppscgym/widgets.dart';

class AddMemberPage extends StatefulWidget {
  final Member? data;
  AddMemberPage({Key? key, this.data}) : super(key: key);

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  late bool update;

  late List<bool> sessionOptions;
  late List<bool> genderOptions;

  final formKey = GlobalKey<FormState>();
  final idCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    setDefaultInfo();
  }

  void setDefaultInfo() {
    // Form status
    update = (widget.data != null) ? true : false;

    // Form data
    if (update) {
      idCtrl.text = widget.data!.id.toString();
      nameCtrl.text = widget.data!.name;
      dobCtrl.text = widget.data!.dob;
      mobileCtrl.text = widget.data!.mobile.toString();

      sessionOptions =
          (widget.data!.session == 'Morning') ? [true, false] : [false, true];
      genderOptions =
          (widget.data!.gender == 'Male') ? [true, false] : [false, true];
    } else {
      sessionOptions = [true, false];
      genderOptions = [true, false];
    }
  }

  @override
  void dispose() {
    super.dispose();
    idCtrl.dispose();
    nameCtrl.dispose();
    dobCtrl.dispose();
    mobileCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      title: (update) ? const Text('Edit Member') : const Text('New Member'),
      actions: <Widget>[
        saveButton(),
      ],
    );
  }

  Widget saveButton() {
    return IconButton(
      icon: const Icon(Icons.check),
      tooltip: 'Save',
      onPressed: () async {
        await handleSave();
      },
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(25.0),
          child: Column(
            children: <Widget>[
              //
              // Member Gender (default: Male)
              //

              ToggleButtons(
                isSelected: genderOptions,
                borderColor: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                children: <Widget>[
                  option('Male'),
                  option('Female'),
                ],
                onPressed: (int index) {
                  setState(() {
                    updateOptions(index, genderOptions);
                  });
                },
              ),
              gapWidget(40.0),

              //
              // Member Workout Session (default: Morning)
              //

              ToggleButtons(
                isSelected: sessionOptions,
                borderColor: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                children: <Widget>[
                  option('Morning'),
                  option('Evening'),
                ],
                onPressed: (int index) {
                  setState(() {
                    updateOptions(index, sessionOptions);
                  });
                },
              ),
              gapWidget(40.0),

              //
              // Member ID
              //

              TextFormFieldWidget(
                enabled: (update) ? false : true,
                maxLength: 12,
                labelText: 'Adhar ID',
                controller: idCtrl,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty || value.length != 12) {
                    return 'Invalid ID';
                  } else {
                    return null;
                  }
                },
              ),
              gapWidget(20.0),

              //
              // Member Name
              //

              TextFormFieldWidget(
                labelText: 'Name',
                controller: nameCtrl,
                keyboardType: TextInputType.name,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z\s]*$'),
                  ),
                ],
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  } else {
                    return null;
                  }
                },
              ),
              gapWidget(20.0),

              //
              // Date Of Birth
              //

              TextFormFieldWidget(
                controller: dobCtrl,
                labelText: 'Date Of Birth',
                enableInteractiveSelection: false,
                keyboardType: TextInputType.text,
                onTap: () async {
                  // Below line stops keyboard from appearing
                  FocusScope.of(context).requestFocus(new FocusNode());

                  DateTime? date = await pickDate(context);
                  if (date != null) {
                    setState(() {
                      dobCtrl.text = toDDMMYYYY(date);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'DOB is required';
                  } else if (!is12YearOld(value)) {
                    return 'You are not 12 year old';
                  } else {
                    return null;
                  }
                },
              ),
              gapWidget(20.0),

              //
              // Member Mob.No.
              //

              TextFormFieldWidget(
                maxLength: 10,
                labelText: 'Mobile',
                controller: mobileCtrl,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 10) {
                    return 'Invalid Mobile Number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget option(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 40.0, right: 40.0),
      child: Text(text),
    );
  }

  void updateOptions(int index, List<bool> options) {
    for (int buttonIndex = 0; buttonIndex < options.length; buttonIndex++) {
      if (buttonIndex == index) {
        options[buttonIndex] = true;
      } else {
        options[buttonIndex] = false;
      }
    }
  }

  //
  // Database Methods
  //

  insertMember(Member member) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.insertMember(member);
  }

  updateMember(Member member) async {
    final DatabaseHandler handler = DatabaseHandler();
    return await handler.updateMember(member);
  }

  Future<void> handleSave() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (formKey.currentState!.validate()) {
      late Member member;
      late String? error;
      if (update) {
        member = Member(
          id: int.parse(idCtrl.text),
          name: formatName(nameCtrl.text),
          gender: getGenderString(genderOptions),
          dob: dobCtrl.text,
          mobile: int.parse(mobileCtrl.text),
          session: getSessionString(sessionOptions),
          planExpiryDate: widget.data!.planExpiryDate,
          planMonth: widget.data!.planMonth,
          totalMoney: widget.data!.totalMoney,
        );
        error = await updateMember(member);
      } else {
        member = Member(
          id: int.parse(idCtrl.text),
          name: formatName(nameCtrl.text),
          gender: getGenderString(genderOptions),
          dob: dobCtrl.text,
          mobile: int.parse(mobileCtrl.text),
          session: getSessionString(sessionOptions),
        );

        error = await insertMember(member);
      }

      if (error != null) {
        errorPopup(context, error);
      } else {
        if (update) {
          // only appear on if values are not same
          if (!mapEquals(widget.data!.toMap(), member.toMap())) {
            infoPopup(context, "${member.name}'s details Updated");
            Navigator.pop(context, 'member updated');
          }
        } else {
          successPopup(context, '${member.name} is now member of the club.');
          Navigator.pop(context, 'member added');
        }
      }
    }
  }
}
