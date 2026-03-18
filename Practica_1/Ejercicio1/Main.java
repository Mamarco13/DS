package Practica_1.Ejercicio1;

import java.util.Scanner;

import Practica_1.Ejercicio1.factory.FactoriaCasual;
import Practica_1.Ejercicio1.factory.FactoriaCompetitiva;
import Practica_1.Ejercicio1.factory.FactoriaPartidaYJugador;

import Practica_1.Ejercicio1.partida.Partida;

public class Main {

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        System.out.print("Introduce el numero de jugadores: ");
        int n_jugadores = sc.nextInt();
        sc.close();

        
        FactoriaPartidaYJugador factoriaCompetitiva = new FactoriaCompetitiva();
        FactoriaPartidaYJugador factoriaCasual = new FactoriaCasual();

        Partida partidaCompetitiva = factoriaCompetitiva.crearPartida(n_jugadores);
        Partida partidaCasual = factoriaCasual.crearPartida(n_jugadores);


        Thread t1 = new Thread(partidaCompetitiva);
        Thread t2 = new Thread(partidaCasual);

        t1.start();
        t2.start();
    }
    
}
