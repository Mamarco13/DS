package Practica_1.Ejercicio1.factory;

import Practica_1.Ejercicio1.jugador.*;
import Practica_1.Ejercicio1.partida.*;

public class FactoriaCasual implements FactoriaPartidaYJugador {

    @Override
    public Partida crearPartida(int numJugadores) {

        Partida partida = new PartidaCasual();

        for(int i = 1; i <= numJugadores; i++) {
            partida.aniadirJugador(crearJugador(i));
        }

        return partida;
    }

    @Override
    public Jugador crearJugador(int id) {
        return new JugadorCasual(id);
    }

}