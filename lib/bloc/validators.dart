import 'dart:async';

class Validators {

  final validateAdhar=
    StreamTransformer<String, String>.fromHandlers(handleData: (adhar, sink) {
    if (adhar!=null) {
      if(adhar==null){
        sink.addError('Enter a Adhar Number');
      }else{
        if(adhar.length<=14){
          if(adhar.toString().length !=14)
            sink.addError('Enter a valid Adhar Number ');
          if(adhar.toString().length==14)
            sink.add(adhar);
        }
      }      
    } 
  });

  final validFirstName =
    StreamTransformer<String, String>.fromHandlers(handleData: (fname, sink) {
    if (fname!=null) {
        sink.add(fname);
    } else {
      sink.addError('First Name is Empty');
    }
  });

  final validLastName =
    StreamTransformer<String, String>.fromHandlers(handleData: (lname, sink) {
    if (lname!=null) {
        sink.add(lname);
    } else {
      sink.addError('First Name is Empty');
    }
  });

  final validMob=
    StreamTransformer<String, String>.fromHandlers(handleData: (mob, sink) {
    if (mob!=null) {
      if(mob==null){
        sink.addError('Enter a Contact Number');
      }else{
        if(mob.length<=11){
          if(mob.toString().length !=11)
            sink.addError('Enter a valid Contact Number ');
          if(mob.toString().length==11)
            sink.add(mob);
        }
      }      
    } 
  });
  
  final validJoinDate=
    StreamTransformer<DateTime, String>.fromHandlers(handleData: (joinDate, sink) {
    if (joinDate.toString()!=null) {
      sink.add(joinDate.toString());
    }
    sink.addError("Select Valid joinDate");
    });
  
}
