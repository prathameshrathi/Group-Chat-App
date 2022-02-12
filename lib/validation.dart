class Validation {
  bool validEmail(String email) {
    bool isValid =
        RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return isValid;
  }

  bool validPass(String pass){
    if(pass.length<6)
      return false;
    return true;
  } 
}
