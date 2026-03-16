from iServicioMedida import iServicioMedida

class ServicioEuropeo(iServicioMedida):
    def __init__(self, adaptee_americano):
        temperaturaF = adaptee_americano.getTemperatura()
        self.temperaturaC = ((temperaturaF - 32) / 1.8)
    
    def getTemperatura(self):
        return self.temperaturaC