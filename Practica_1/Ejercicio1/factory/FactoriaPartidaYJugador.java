package Practica_1.Ejercicio1.factory;

import Practica_1.Ejercicio1.jugador.Jugador;
import Practica_1.Ejercicio1.partida.Partida;


public interface FactoriaPartidaYJugador {

    Partida crearPartida(int numJugadores);
    Jugador crearJugador(int id);
}
