package Practica_1.Ejercicio1.factory;

import Practica_1.Ejercicio1.partida.*;
import Practica_1.Ejercicio1.jugador.*;


public class FactoriaCompetitiva implements FactoriaPartidaYJugador{

    @Override
    public Partida crearPartida() {
        return new PartidaCompetitiva();
    }

    @Override
    public Jugador crearJugador(int id){
        return new JugadorCompetitivo(id);
    }
    
    
}
