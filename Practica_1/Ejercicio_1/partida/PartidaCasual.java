package Practica_1.Ejercicio1.partida;

public class PartidaCasual extends Partida {

    @Override
    public void run(){
        
        System.out.println("Partida casual inicia con " + jugadores.size() + " jugadores");


        //Los jugaores que abandonen tienen que abandonar al mimso tiempo antes de que acabe la partida, 
        //he puesto valor arbitrario de que abandonen a los 40 segundos, como tiene que durar 60 segundo la partida, una vez se 
        //produce el abandono, tardar 20 segundos en finalizar.

        
        try {
            Thread.sleep(40000);

            int abandonos = (int)(jugadores.size() * 0.10);

            for(int i = 0; i < abandonos; i++) {
                jugadores.remove(jugadores.size() - 1);
            }

            System.out.println("En la partida casual han abandonado: " + abandonos + " jugadores");
            
            Thread.sleep(20000);

        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Partida casual termina con " + jugadores.size() + " jugadores");
        

    }
    
}
