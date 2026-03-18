package Practica_1.Ejercicio1.partida;

public class PartidaCompetitiva extends Partida {
    
    @Override
    public void run(){
        
        System.out.println("Partida competitiva inicia con " + jugadores.size() + " jugadores");

        try {
            Thread.sleep(40000); // mitad de partida

            int abandonos = (int)(jugadores.size() * 0.20);

            for(int i = 0; i < abandonos; i++) {
                jugadores.remove(jugadores.size() - 1);
            }


            System.out.println("En la partida competitiva han abandonado:  " + abandonos + " jugadores");
            
        
            Thread.sleep(20000);
            
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        System.out.println("Partida competitiva terminada con " + jugadores.size() + " jugadores");

    }
}
