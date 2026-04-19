import '../models/secret_keeper.dart';

abstract class SecretKeeperDecorator implements SecretKeeper {
  // Referencia al objeto que se está decorando
  final SecretKeeper wrappee;

  SecretKeeperDecorator(this.wrappee);

  @override
  // Delega la palabra secreta al objeto base
  String get secretWord => wrappee.secretWord;

  @override
  // Delega la llamada al siguiente elemento de la cadena
  // Los decoradores concretos pueden sobrescribir este método
  // para añadir comportamiento antes o después
  Future<String> ask(String userMessage, {String? prompt}) {
    return wrappee.ask(userMessage, prompt: prompt);
  }
}