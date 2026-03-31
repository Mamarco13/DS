from iServicioMedida import iServicioMedida

class ServicioEuropeo(iServicioMedida):
    OFFSET = 32
    FACTOR = 1.8

    def __init__(self, adaptee_americano):
        temperaturaF = adaptee_americano.getTemperatura()
        self.temperaturaC = ((temperaturaF - self.OFFSET) / self.FACTOR)
    
    def getTemperatura(self):
        return self.temperaturaC