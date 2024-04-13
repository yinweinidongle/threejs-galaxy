<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"

let base,controls,gui,clock;
let ghost1,ghost2,ghost3;
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 15
    base.camera.updateProjectionMatrix()
    base.addAmbientLight(1,0xb9d5ff)
    base.addDirectionalLight(0.5,0xb9d5ff)
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    window.addEventListener("resize",resize)
    //createBox();



    //Fog
    const fog = new THREE.Fog('#262837',1,25)
    base.scene.fog = fog 
    

    //Group
    const house = new THREE.Group()
    base.scene.add(house)

    //Door light
    const doorLight = new THREE.PointLight('#ff7d46',10,7)
    doorLight.position.set(0,2.2,2.7)
    doorLight.castShadow = true
    house.add(doorLight)

    //walls
    const walls = new THREE.Mesh(
        new THREE.BoxGeometry( 4, 2.5, 4 ),
        new THREE.MeshLambertMaterial( {color: 0xac8e82} )
    )

    walls.position.y = 1.26
    walls.castShadow = true
    house.add(walls)


    //Roof
    const roof = new THREE.Mesh(new THREE.ConeGeometry( 3.5, 1, 4 ), new THREE.MeshLambertMaterial( {color: 0xb35f45} ) ); 
    roof.position.y = 2.5 + 0.5
    roof.rotation.y = Math.PI*0.25
    roof.castShadow = true
    house.add( roof );

    //Door
    const door = new THREE.Mesh(
        new THREE.PlaneGeometry( 2, 2 ),
        new THREE.MeshLambertMaterial( {color: 0x0000ff, side: THREE.DoubleSide} )
    )
    door.position.y = 1
    door.position.z = 2+0.01
    door.castShadow = true
    house.add( door );


    //Bushes
    const bushGeometry = new THREE.SphereGeometry(1,16,16)
    const bushMaterial = new THREE.MeshLambertMaterial({color:"#89c854"})

    const bush1 = new THREE.Mesh(bushGeometry,bushMaterial)
    const bush2 = new THREE.Mesh(bushGeometry,bushMaterial)
    const bush3 = new THREE.Mesh(bushGeometry,bushMaterial)
    const bush4 = new THREE.Mesh(bushGeometry,bushMaterial)
    bush1.scale.set(0.5,0.5,0.5)
    bush2.scale.set(0.25,0.25,0.25)
    bush1.position.set(0.8,0.2,2.2)
    bush2.position.set(1.4,0.1,2.1)
    bush3.scale.set(0.4,0.4,0.4)
    bush3.position.set(-0.8,0.1,2.2)
    bush4.scale.set(0.15,0.15,0.15)
    bush4.position.set(-1,0.05,2.6)

    bush1.castShadow = true
    bush2.castShadow = true
    bush3.castShadow = true
    bush4.castShadow = true

    house.add(bush1,bush2,bush3,bush4)


    //Graves
    const graves = new THREE.Group()
    base.scene.add(graves)

    const graveGeometry= new THREE.BoxGeometry( 0.6, 0.8, 0.2 )
    const graveMaterial = new THREE.MeshLambertMaterial( {color: '#b2b6b1'} )

    for(let i=0;i<50;i++){
        const angle = Math.random()*Math.PI*2
        const radius = 3 + Math.random()*6
        const x = Math.sin(angle)*radius
        const z = Math.cos(angle)*radius

        const grave = new THREE.Mesh(graveGeometry,graveMaterial)
        grave.position.set(x,0.3,z)
        grave.rotation.y = (Math.random()-0.5)*1
        grave.rotation.z = (Math.random()-0.5)*1
        grave.castShadow = true
        graves.add(grave)
    }





    //Floor
    const floor = new THREE.Mesh(
        new THREE.PlaneGeometry( 20, 20 ),
        new THREE.MeshLambertMaterial( {color: 0xa9c388, side: THREE.DoubleSide} )
    )

    floor.rotation.x = -Math.PI*0.5
    floor.position.y =0
    floor.castShadow = true
    base.scene.add(floor)



    //Ghosts
    ghost1 = new THREE.PointLight('#ff00ff',2,3)
    ghost2 = new THREE.PointLight('#00ffff',2,3)
    ghost3 = new THREE.PointLight('#ffff00',2,3)

    ghost1.castShadow = true
    ghost2.castShadow = true
    ghost3.castShadow = true

    base.scene.add(ghost1,ghost2,ghost3)

    update()

   


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const elapsedTime = clock.getElapsedTime()*0.5
    
    ghost1.position.x = Math.cos(elapsedTime) * 4
    ghost1.position.z = Math.sin(elapsedTime) * 4
    ghost1.position.y = Math.sin(elapsedTime) * 2

    ghost2.position.x = Math.cos(-elapsedTime) * 4
    ghost2.position.z = Math.sin(-elapsedTime) * 4
    ghost2.position.y = Math.sin(-elapsedTime) * 1 + Math.sin(-elapsedTime) * 2.5

    ghost3.position.x = Math.cos(-elapsedTime) * 5
    ghost3.position.z = Math.sin(-elapsedTime) * 5




    requestAnimationFrame(update)
    base.update()
    controls.update()
    
}

function resize(){
    base.resize();
}

</script>

<template>
  
</template>

<style scoped>

</style>
