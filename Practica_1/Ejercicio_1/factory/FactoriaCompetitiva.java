package Practica_1.Ejercicio1.factory;

import Practica_1.Ejercicio1.partida.*;
import Practica_1.Ejercicio1.jugador.*;


public class FactoriaCompetitiva implements FactoriaPartidaYJugador {

    @Override
    public Partida crearPartida(int numJugadores) {

        Partida p = new PartidaCompetitiva();

        for(int i = 1; i <= numJugadores; i++) {
            p.aniadirJugador(crearJugador(i));
        }

        return p;
    }

    @Override
    public Jugador crearJugador(int id) {
        return new JugadorCompetitivo(id);
    }

}
