<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "./Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"

let base,controls,gui;
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 5
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    update()
    window.addEventListener("resize",resize)
    //createBox();

    /**
     * galaxy
     */
    const parameters = {}
    parameters.count = 100000
    parameters.size = 0.01
    parameters.radius = 5
    parameters.branches = 3
    parameters.spin = 1
    parameters.randomness = 0.2
    parameters.randomnessPower = 3
    parameters.insideColor = "#ff6030"
    parameters.outsideColor = "#1b3984"


    let geometry = null
    let material = null
    let points = null

    const generateGalaxy = ()=>{

        /**
         * destroy old galaxy
         */
        if(points !== null){
            geometry.dispose()
            material.dispose()
            base.scene.remove(points)
        }

        geometry = new THREE.BufferGeometry()
        const positions = new Float32Array(parameters.count*3)
        const colors = new Float32Array(parameters.count*3)

        const colorInside = new THREE.Color(parameters.insideColor)
        const colorOutside = new THREE.Color(parameters.outsideColor)

        for(let i=0;i<parameters.count;i++){
            const i3 = i*3

            //position
            const radius = Math.random() * parameters.radius
            const spinAngle = radius * parameters.spin
            const branchAngle = (i%parameters.branches)/parameters.branches * Math.PI * 2

            const randomX = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)
            const randomY = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)
            const randomZ = Math.pow(Math.random(),parameters.randomnessPower)*(Math.random()<0.5?1:-1)

            positions[i3+0] = Math.cos(branchAngle+spinAngle)*radius+randomX
            positions[i3+1] = randomY
            positions[i3+2] = Math.sin(branchAngle+spinAngle)*radius+randomZ
            
            //color

            const mixedColor = colorInside.clone()
            mixedColor.lerp(colorOutside,radius/parameters.radius)

            colors[i3+0] = mixedColor.r
            colors[i3+1] = mixedColor.g
            colors[i3+2] = mixedColor.b
        }

        geometry.setAttribute(
            'position',
            new THREE.BufferAttribute(positions,3)
        )

        geometry.setAttribute(
            'color',
            new THREE.BufferAttribute(colors,3)
        )

        /**
         * Material
         */
        material = new THREE.PointsMaterial({
            size:parameters.size,
            sizeAttenuation:true,
            depthWrite:false,
            blending:THREE.AdditiveBlending,
            vertexColors:true
        })
        /**
         * points
         */
        points = new THREE.Points(geometry,material)
        base.scene.add(points)
    }

    generateGalaxy()
    gui.add(parameters,'count').min(100).max(100000).step(100).onFinishChange(generateGalaxy)
    gui.add(parameters,'size').min(0.001).max(0.1).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'radius').min(0.01).max(20).step(0.01).onFinishChange(generateGalaxy)
    gui.add(parameters,'branches').min(1).max(10).step(1).onFinishChange(generateGalaxy)
    gui.add(parameters,'spin').min(-5).max(5).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'randomness').min(0).max(2).step(0.001).onFinishChange(generateGalaxy)
    gui.add(parameters,'randomnessPower').min(1).max(10).step(0.001).onFinishChange(generateGalaxy)

    gui.addColor(parameters,'insideColor').onFinishChange(generateGalaxy)
    gui.addColor(parameters,'outsideColor').onFinishChange(generateGalaxy)


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

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
