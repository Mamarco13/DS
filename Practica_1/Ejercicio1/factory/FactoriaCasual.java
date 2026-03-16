package Practica_1.Ejercicio1.factory;

import Practica_1.Ejercicio1.jugador.*;
import Practica_1.Ejercicio1.partida.*;

public class FactoriaCasual implements FactoriaPartidaYJugador {

    @Override
    public Partida crearPartida() {
        return new PartidaCasual();
    }

    @Override
    public Jugador crearJugador(int id) {
        return new JugadorCasual(id);
    }
    
}