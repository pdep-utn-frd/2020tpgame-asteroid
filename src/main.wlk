import wollok.game.*

class ElementoDelEspacio {

	var property evento = null
	var property image = null
	var property position = null

	method desaparece() {
		if (game.hasVisual(self)) {
			game.removeTickEvent(evento)
			game.removeVisual(self)
		}
	}
}

class Asteroide inherits ElementoDelEspacio {

	method danio() = 30

	method impactoDeBala(bala) {
		self.desaparece()
	}

	method chocasteALaNave() {
		self.desaparece()
	}

	method avanza() {
		position = self.position().down(0.5)
		if (!juego.estaEnElTablero(position)) {
			self.desaparece()
		}
	}

	method aparece() {
		evento = juego.generarNombreEvento('asteroid')
		image = [ "asteroid.png", "asteroid_big1.png", "asteroid_medium3.png" ].anyOne()
		const x = (0 .. game.width() - 2).anyOne()
		const y = game.height() - 1
		position = game.at(x, y)
		game.addVisual(self)
		game.onTick(100, evento, { self.avanza()})
	}

}

class Bala inherits ElementoDelEspacio {

	method impactoDeBala(param1) {
	}

	method chocasteALaNave() {
	}

	method danio() = 40

	method avanza(hacia) {
		if (juego.estaEnElTablero(hacia)) {
			position = hacia
		} else {
			self.desaparece()
		}
	}

}

class BalaNave inherits Bala {

	method disparar() {
		evento = juego.generarNombreEvento('disparoNave')
		image = "lasery.png"
		position = nave.position().up(1)
		game.addVisual(self)
		game.onCollideDo(self, { elemento => elemento.impactoDeBala(self)})
		game.onTick(20, evento, { self.avanza(self.position().up(1))})
	}

}

class BalaEnemiga inherits Bala {

	override method danio() = super() * 2

	override method chocasteALaNave() {
		self.desaparece()
	}

	method disparar(naveEnemiga) {
		evento = juego.generarNombreEvento('disparoEnemigo')
		image = "laser_enemy.png"
		self.position(naveEnemiga.position().down(1))
		game.addVisual(self)
		game.onTick(20, evento, { self.avanza(self.position().down(1))})
	}

}

object juego {

	var property enemigosVivos = 1
	var contadorEventos = 1000000

	method configurate() {
		game.clear()
		game.title("Asteroids")
		game.width(15)
		game.height(15)
		game.boardGround("background.jpeg")
		game.onTick(1000, 'generarAsteroide', { new Asteroide().aparece()})
		game.onTick(5000, 'generarEnemigo', { self.generarNuevoEnemigo()})
		nave.config()
		new Enemigo().config()
	}

	method estaEnElTablero(ubicacion) = ubicacion.x().between(0, game.width()) && ubicacion.y().between(-5, game.height())

	method generarNombreEvento(subfijo) {
		contadorEventos += 1
		return contadorEventos.toString() + subfijo
	}

	method matarEnemigo() {
		enemigosVivos -= 1
	}

	method generarNuevoEnemigo() {
		if (enemigosVivos < 2) {
			new Enemigo().config()
			enemigosVivos += 1
		}
	}

	method gameOver() {
		game.clear()
		game.addVisual(gameOver)
		self.enemigosVivos(1)
		keyboard.enter().onPressDo{ self.configurate()}
	}

}

object gameOver {

	method image() = 'gameOver.png'

	method position() = game.at(5, 7)

}

object nave inherits ElementoDelEspacio {

	var property vida

	method impactoDeBala(bala) {
	}

	method config() {
		position = game.center()
		image = 'nave.png'
		vida = 500
		self.controles()
		game.addVisualCharacter(self)
		game.onCollideDo(self, { elemento => // Asteroide y disparos enemigos
			elemento.chocasteALaNave()
			self.actualizarVida(elemento.danio())
		})
	}

	method nuevoDisparo() {
		new BalaNave().disparar()
	}

	method controles() {
		keyboard.space().onPressDo{ self.nuevoDisparo()}
	}

	method actualizarVida(cantidad) {
		vida = vida - cantidad
		if (vida > 0) {
			game.say(self, 'vida: ' + self.vida().toString())
		} else {
			juego.gameOver()
		}
	}

}

class Enemigo inherits ElementoDelEspacio {

	var property vida = 600
	const evento2 = juego.generarNombreEvento('movete')

	override method desaparece() {
		if (game.hasVisual(self)) {
			game.removeTickEvent(evento)
			game.removeTickEvent(evento2)
			game.removeVisual(self)
		}
	}
	
	method danio() = nave.vida()
	
	method chocasteALaNave() {}

	method estaMasALaDerechaQue(elemento) = elemento.position().x() > self.position().x()

	method estoyApuntandoA(elemento) = elemento.position().x() == self.position().x()

	method puedoMoverme(direccion) = game.getObjectsIn(direccion).size() == 0

	method impactoDeBala(bala) {
		vida -= 80
		if (vida > 0) {
			game.say(self, 'vida: ' + self.vida().toString())
		} else {
			self.desaparece()
			juego.matarEnemigo()
		}
	}

	method config() {
		evento = juego.generarNombreEvento('disparar')
		image = "enemy.png"
		self.generarEnemigo()
		game.onTick(800, evento, { self.nuevoDisparo()})
		game.onTick(1000, evento2, { if (!self.estoyApuntandoA(nave)) {
				self.cambiaPosicion()
			}
		})
	}

	method generarEnemigo() {
		self.puedoAparecerEn(self.generarCoordenada())
	}

	method generarCoordenada() {
		const x = (0 .. game.width() - 2).anyOne()
		const y = game.height() - 3
		return game.at(x, y)
	}

	method puedoAparecerEn(coordenadas) {
		if (game.getObjectsIn(coordenadas).size() == 0) {
			position = coordenadas
			game.addVisual(self)
		} else {
			self.generarEnemigo()
		}
	}

	method moverseHacia(posiciones) {
		if (self.puedoMoverme(position.right(2 * posiciones))) {
			self.position(position.right(posiciones))
		}
	}

	method cambiaPosicion() {
		self.moverseHacia(if (self.estaMasALaDerechaQue(nave)) {
			1
		} else {
			-1
		})
	}

	method nuevoDisparo() {
		if (game.hasVisual(self)) {
			new BalaEnemiga().disparar(self)
		}
	}

}

