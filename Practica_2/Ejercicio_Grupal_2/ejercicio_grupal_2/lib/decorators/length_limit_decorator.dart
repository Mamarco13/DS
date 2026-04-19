import 'secret_keeper_decorator.dart';
import '../utils/filters_config.dart';

class LengthLimitDecorator extends SecretKeeperDecorator {
  LengthLimitDecorator(super.wrappee);

  @override
  Future<String> ask(String userMessage, {String? prompt}) async {
    // Bloquea mensajes que superan la longitud máxima permitida
    if(userMessage.length > FiltersConfig.maxLength){
      return "📏 Mensaje demasiado largo. No voy a leer eso.";
    }

    // Si cumple la condición, delega al siguiente elemento de la cadena
    return wrappee.ask(userMessage, prompt: prompt);
  }
}