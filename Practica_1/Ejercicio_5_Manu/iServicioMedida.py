from abc import ABC, abstractmethod

class iServicioMedida(ABC):
    @abstractmethod
    def getTemperatura(self):
        pass