package Practica_1.Ejercicio1.partida;

import Practica_1.Ejercicio1.jugador.Jugador;
import java.util.ArrayList;

public abstract class Partida implements Runnable{

    protected ArrayList<Jugador> jugadores = new ArrayList<>();

    public Partida(){
        jugadores = new ArrayList<>();
    }

    public void aniadirJugador(Jugador jugador) {
        jugadores.add(jugador);
    }
    
}
