/* construct manually */
var Health = new ldBar(".Health");
var Armor = new ldBar(".Armor");
var food = new ldBar(".food");
var thirst = new ldBar(".thirst");
/* ldBar stored in the element */

const clock = document.querySelector(".clock") ;

window.addEventListener("load",time) ;

function time() {
	let d = new Date() ;
	let h = d.getHours() ;
	let m = d.getMinutes() ;
	let s = d.getSeconds() ;
	m = check(m) ;
	s = check(s);
	clock.textContent = `${h}:${m}` ;
	setTimeout(time,1000) ;
}

function check(t){
	if(t < 10) return '0' + t ;
	return t ;
}

window.addEventListener('message', function (event) {
    let data = event.data;
	
	if(event.data.show == true)
	{
		$('.UI').show();
	} else {
		$('.UI').hide();
	}
		
	Armor.set(Math.round(data.armour));
	food.set(Math.round(data.food));
	thirst.set(Math.round(data.thirst));
    
	if (data.health != -100){
		Health.set(Math.round(data.health));
	}else if(data.health == -100){
		Health.set(0);
	}
	
	if (data.InCar) {
		$('.currentSpeed').html(data.speed);
		$('.speed').show();
		
		if (data.seat) {
			$('.seatOn').show();
			$('.seatOff').hide();
		} else {
			$('.seatOn').hide();
			$('.seatOff').show();
		}
	
		if (data.speedwarn) {
			$('.SpeedWarn').show();
		} else {
			$('.SpeedWarn').hide();
		}
	} else {
		$('.speed').hide();
		$('.seatOn').hide();
		$('.seatOff').hide();
		$('.SpeedWarn').hide();
	}
});