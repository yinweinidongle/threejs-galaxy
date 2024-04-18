<script setup>
import {onMounted} from "vue";
import * as THREE from 'three'
import Base from "../Base";
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import {GUI} from "three/examples/jsm/libs/lil-gui.module.min.js"
import galaxyVertexShader from './shader/vertex.glsl?raw'
import galaxyFragmentShader from './shader/fragment.glsl?raw'
import {GLTFLoader} from 'three/examples/jsm/loaders/GLTFLoader.js'
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js'

let base,controls,gui,clock,points;
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z = 1114
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const ambientLight = new THREE.AmbientLight( 0xcccccc, 0.4 );
	base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 0.6 );
				directionalLight.position.set( - 1, 1, 1 );
	base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/skybox/' );

				const cubeTexture = cubeTextureLoader.load( [
					"px.jpg", "nx.jpg",
					"py.jpg", "ny.jpg",
					"pz.jpg", "nz.jpg"
				] );

	base.scene.background = cubeTexture;

   
    const particles = 500;

				const geometry = new THREE.BufferGeometry();

				const positions = [];
				const colors = [];

				const color = new THREE.Color();

				const n = 100, n2 = n / 2; // particles spread in the cube

                const coneBaseRadius = 100;
                const coneHeight = 20;
                const coneSegments = 35; // 控制点云分辨率，越大越精细
                const pointCount = coneSegments * coneSegments; // 每个圆环上点的数量


				for ( let i = 0; i < particles; i ++ ) {

					// positions

					const theta = i / coneSegments * 2 * Math.PI;

                    console.log(theta)

                    const x = theta * Math.cos(theta);
                    const y = theta * 0.5; // 假设锥体高度的一半
                    const z = theta * Math.sin(theta);
                    

                    let xyz = randomInUnitSphere()
                    positions.push( x,y,z );
					//positions.push( ...xyz );

					

				}

                console.log(positions)


                function randomInUnitSphere() {
                    do {
                        var x = Math.random() * 100 - 50;
                        var y = Math.random() * 100 - 50;
                        var z = Math.random() * 100 - 50;
                        var length = x * x + y * y + z * z;
                    } while (length >= 100 || length <= 0);

                    return [x,y,z];
                    }

				geometry.setAttribute( 'position', new THREE.Float32BufferAttribute( positions, 3 ) );
				geometry.setAttribute( 'color', new THREE.Float32BufferAttribute( colors, 3 ) );

				geometry.computeBoundingSphere();

				//

				material = new THREE.ShaderMaterial({
                    uniforms: {
                        uColor: {
                            value: new THREE.Color('#FFFF00')
                        },
                        uTime:{value:0},
                        texture: { value: null },
                        uSzie: {
                            value: 2
                        }
                    },
                    vertexShader: `
                        uniform float uSzie;
                        uniform float uTime;
                        //varying float vLife;
                        void main() {
                            // 顶点着色器计算后的Position
                            //vec3 newPosition = position + 4*uTime;
                            //gl_Position = projectionMatrix * modelViewMatrix * vec4(cos(position.x*uTime*0.1)+position.x,position.y,position.z, 1.0);
                            
                            vec4 modelPosition = modelMatrix * vec4(position,1.0);


                           
                            modelPosition.x = (modelPosition.x);
                            modelPosition.y = (modelPosition.y);
                            modelPosition.z = (modelPosition.z);

                            

                            vec4 viewPosition = viewMatrix * modelPosition;
                            vec4 projectedPosition = projectionMatrix * viewPosition;

                            gl_Position = projectedPosition;
                            
                            
                            //vLife = 3.0;
                            // 永远为10像素大小
                            gl_PointSize = uSzie;
                        }`,
                    fragmentShader: `
                        
                        uniform vec3 uColor;
                        //varying float vLife;
                        void main() {
                            
                            //vec4 color = texture2D(texture, gl_PointCoord);
                            //color.a *= smoothstep(0.0, 1.0, 4); // 随生命值降低而逐渐透明

                            gl_FragColor = vec4(0.0, 1.0, 1.0,0.5);
                        }`
                });

				points = new THREE.Points( geometry, material );
				base.scene.add( points );


                const loader = new GLTFLoader();
    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    //dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    dracoLoader.setDecoderPath( '/draco/' )
    loader.setDRACOLoader( dracoLoader );

                loader.load(
        "/farmland_0415.glb",
        function ( gltf ) {
            gltf.scene.scale.set(100,100,100)
            gltf.scene.position.x = 0;
            gltf.scene.position.y = -100;
            gltf.scene.position.z = 0;
            gltf.scene.rotation.y = Math.PI ;
            //gltf.scene.rotation.x = Math.PI*0.1 ;
            base.scene.add( gltf.scene );
        }
    );


    update()


});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const elapsedTime = clock.getDelta()
    material.uniforms.uTime.value += elapsedTime

    points.rotation.y += elapsedTime*2000

    // const ratio = elapsedTime
    
    // points.scale.x += ratio
    // points.scale.y += ratio
    // points.scale.z += ratio

    // if(points.scale.x>3){
    //     points.scale.x = 1
    //     points.scale.y = 1
    //     points.scale.z = 1
    // }

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
