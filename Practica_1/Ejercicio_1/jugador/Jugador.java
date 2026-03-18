package Practica_1.Ejercicio1.jugador;

public abstract class Jugador {
    
    protected int id;

    public Jugador(int id) {
            this.id = id;
        }
    
    public int getId() {
        return id;
    }
}
