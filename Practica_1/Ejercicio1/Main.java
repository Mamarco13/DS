package Practica_1.Ejercicio1;

import Practica_1.Ejercicio1.factory.*;
import Practica_1.Ejercicio1.jugador.*;
import Practica_1.Ejercicio1.partida.*;
import Practica_1.Ejercicio1.simulacion.*;
import java.util.Scanner;

public class Main {

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.print("Introduce el numero de jugadores: ");
        int N = sc.nextInt();
        sc.close();

        
        FactoriaPartidaYJugador factoriaCompetitiva = new FactoriaCompetitiva();
        FactoriaPartidaYJugador factoriaCasual = new FactoriaCasual();

        Partida partidaCompetitiva = factoriaCompetitiva.crearPartida();
        Partida partidaCasual = factoriaCasual.crearPartida();

        for (int i = 1; i <= N; i++) {

            Jugador jugador_comp = factoriaCompetitiva.crearJugador(i);
            Jugador jugador_casual = factoriaCasual.crearJugador(i);

            partidaCompetitiva.aniadirJugador(jugador_comp);
            partidaCasual.aniadirJugador(jugador_casual);
        }

        Thread t1 = new Thread(new Simulacion(partidaCompetitiva));
        Thread t2 = new Thread(new Simulacion(partidaCasual));

        t1.start();
        t2.start();
    }
    
}
