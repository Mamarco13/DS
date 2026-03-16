package Practica_1.Ejercicio1.simulacion;

import Practica_1.Ejercicio1.partida.*;

public class Simulacion implements Runnable{

    private Partida partida;

    public Simulacion(Partida partida){
        this.partida = partida;
    }

    @Override
    public void run(){

        int jugadoresInicio = partida.getJugadores().size();
        System.out.println("Jugadores que inician la partida: " + jugadoresInicio);

        try {
            Thread.sleep(60000); //La partida tiene que durar 60 segundo NO TOCAR!!
        } catch (InterruptedException e){
            e.printStackTrace();
        }

        /*Dice que tienen abandonar al mismo tiempo, no cuando
        creo que está bien planteado, revisar para estar de acuerdo!!
        */
        int abandonos = (int)(jugadoresInicio * partida.porcentajeAbandono());
        int jugadoresFin = jugadoresInicio - abandonos;



        System.out.println("Jugadores que han abandonado: " + abandonos);
        System.out.println("Jugadores que han terminado: " + jugadoresFin);

    }


    //CREO QUE DEBERIA PASARLO TODO ESTO AL MAIN, PERO LO DEJO AQUI POR SI HAY QUE HACER ALGUNA COSA MAS EN LA SIMULACION, REVISAR PARA ESTAR DE ACUERDO!!

    
}
