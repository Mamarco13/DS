package Practica_1.Ejercicio1.partida;

import Practica_1.Ejercicio1.jugador.Jugador;
import java.util.ArrayList;

public abstract class Partida {

    protected ArrayList<Jugador> jugadores = new ArrayList<>();

    public void aniadirJugador(Jugador jugador) {
        jugadores.add(jugador);
    }
    
    public ArrayList<Jugador> getJugadores() {
        return jugadores;
    }

    public abstract double porcentajeAbandono();
}
