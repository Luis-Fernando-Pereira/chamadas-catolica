import 'package:appchamada/model/user.dart';

class Administrator extends User{
  
  Administrator({required int id}) : super.idOnly(id: id);

  Administrator.user({
    required super.id, 
    super.email,
    super.isOnline,
    super.name,
    super.password,
    super.token,
    super.username 
  });

  AssignedClass changeClassStatus(AssignedClass selectedClass, ClassStatus classStatus) {
    selectedClass.status = classStatus;

    //TODO: salvar no banco de dados

    return selectedClass;
  }


}