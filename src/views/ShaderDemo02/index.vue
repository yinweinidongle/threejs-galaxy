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
import { Water } from 'three/examples/jsm/objects/Water.js'
import { Sky } from 'three/examples/jsm/objects/Sky.js'


import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js';
import { OutlinePass } from 'three/examples/jsm/postprocessing/OutlinePass.js';
import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js';

import mirrirVertexShader from './shader/vertexMirror.glsl?raw'
import mirrirFragmentShader from './shader/fragmentMirror.glsl?raw'

import mirrirVertexShader1 from './shader/vertexMirror1.glsl?raw'
import mirrirFragmentShader1 from './shader/fragmentMirror1.glsl?raw'

let base,controls,gui,clock,planeMaterial,mirror,mirror1,portalLightMaterial,portalLightMaterial1,loaderTractorFlag,loaderTractorFlag1,water,sun;

let composer, effectFXAA, outlinePass;
let selectedObjects = [];
const raycaster = new THREE.Raycaster();
const mouse = new THREE.Vector2();
let material = null
onMounted(()=>{
    base = new Base()
    base.camera.position.z =114
    base.camera.updateProjectionMatrix()
    controls = new OrbitControls(base.camera,base.renderer.domElement)
    gui = new GUI({width:300})
    clock = new THREE.Clock()
    
    window.addEventListener("resize",resize)
    //createBox();

     // light

     const ambientLight = new THREE.AmbientLight( 0xcccccc, 1);
	//base.scene.add( ambientLight );

				const directionalLight = new THREE.DirectionalLight( 0xffffff, 1 );
				directionalLight.position.set( - 1, 1, 1 );
	//base.scene.add( directionalLight );


     // skybox

     const cubeTextureLoader = new THREE.CubeTextureLoader();
				cubeTextureLoader.setPath( '/skybox/' );

				const cubeTexture = cubeTextureLoader.load( [
					"px.jpg", "nx.jpg",
					"py.jpg", "ny.jpg",
					"pz.jpg", "nz.jpg"
				] );

	//base.scene.background = cubeTexture;



    portalLightMaterial = new THREE.ShaderMaterial({
        vertexShader:mirrirVertexShader,
        fragmentShader:mirrirFragmentShader,
        side: THREE.DoubleSide,
        transparent:true,
        uniforms:{
            uFrequency:{value:new THREE.Vector2(10,5)},
            uTime:{value:0}
        }
    })

    portalLightMaterial1 = new THREE.ShaderMaterial({
        vertexShader:mirrirVertexShader1,
        fragmentShader:mirrirFragmentShader1,
        side: THREE.DoubleSide,
        transparent:true,
        uniforms:{
            uFrequency:{value:new THREE.Vector2(10,5)},
            uTime:{value:0}
        }
    })



   
   const planeGeometry = new THREE.PlaneGeometry(2,2,32,32)

   const count = planeGeometry.attributes.position.count
   const randoms = new Float32Array(count)

   const textureLoader = new THREE.TextureLoader()
   const flagTexture = textureLoader.load("/canada.png")

   for(let i=0;i<count;i++){
    randoms[i] = Math.random()
   }
   planeGeometry.setAttribute("aRandom",new THREE.BufferAttribute(randoms,1))

   console.log(planeGeometry)
   planeMaterial = new THREE.ShaderMaterial({
     vertexShader:galaxyVertexShader,
     fragmentShader:galaxyFragmentShader,
     side: THREE.DoubleSide,
     transparent:true,
     uniforms:{
        uFrequency:{value:new THREE.Vector2(10,5)},
        uTime:{value:0},
        uTexture:{value:flagTexture}
     }
   });

   const planeMesh = new THREE.Mesh(planeGeometry,planeMaterial)

  
   //base.scene.add(planeMesh)



   const loader = new GLTFLoader();
    // Optional: Provide a DRACOLoader instance to decode compressed mesh data
    const dracoLoader = new DRACOLoader();
    //dracoLoader.setDecoderPath( '/examples/jsm/libs/draco/' );
    dracoLoader.setDecoderPath( '/draco/' )
    loader.setDRACOLoader( dracoLoader );
    // Load a glTF resource
    loader.load(
        "/mirror.glb",
        function ( gltf ) {

            mirror = gltf.scene
            mirror.scale.set(1,1,1)
            mirror.position.x = -3;
            mirror.position.y = 0;
            mirror.position.z = -20;
            //gltf.scene.rotation.x = Math.PI*0.1 ;

            const portalLightMesh = mirror.children.find(child => child.name === 'cycle')

            console.log(portalLightMesh)

            portalLightMesh.material = portalLightMaterial



         
            base.scene.add( mirror );
            //gui.add(drone.position,'x').min(0).max(20).step(0.001).name('droneX')
            //gui.add(group.position,'x').min(0).max(10).step(0.001).name('droneX')
            loaderTractorFlag = true
            
        }
    );


    loader.load(
        "/mirror.glb",
        function ( gltf ) {
            mirror1 = gltf.scene
            mirror1.scale.set(1,1,1)
            mirror1.scale.set(1.5,1.5,1.5)
            mirror1.position.x = 4.5;
            mirror1.position.y = 0;
            mirror1.position.z = -20;
            const portalLightMesh = mirror1.children.find(child => child.name === 'cycle')
            console.log(portalLightMesh)
            portalLightMesh.material = portalLightMaterial1
            base.scene.add( mirror1 );
            loaderTractorFlag1 = true


        }
    );


    loader.load(
        "/town.glb",
        function ( gltf ) {
            gltf.scene = gltf.scene
            gltf.scene.scale.set(1,1,1)
            gltf.scene.scale.set(1.5,1.5,1.5)
            gltf.scene.position.x = 4.5;
            gltf.scene.position.y = 0;
            gltf.scene.position.z = 0;
            base.scene.add( gltf.scene );
        }
    );



    

    // Water
    sun = new THREE.Vector3();

    const waterGeometry = new THREE.PlaneGeometry( 10000, 10000 );

    water = new Water(
        waterGeometry,
        {
            textureWidth: 512,
            textureHeight: 512,
            waterNormals: new THREE.TextureLoader().load( '/waternormals.jpg', function ( texture ) {

                texture.wrapS = texture.wrapT = THREE.RepeatWrapping;

            } ),
            sunDirection: new THREE.Vector3(),
            sunColor: 0xffffff,
            waterColor: 0x001e0f,
            distortionScale: 3.7,
            fog: base.scene.fog !== undefined
        }
    );

    water.position.y = -20
    water.rotation.x = - Math.PI / 2;

    base.scene.add( water );

    


    // Skybox

    const sky = new Sky();
				sky.scale.setScalar( 10000 );
				base.scene.add( sky );

				const skyUniforms = sky.material.uniforms;

				skyUniforms[ 'turbidity' ].value = 10;
				skyUniforms[ 'rayleigh' ].value = 2;
				skyUniforms[ 'mieCoefficient' ].value = 0.005;
				skyUniforms[ 'mieDirectionalG' ].value = 0.8;

				const parameters = {
					elevation: 2,
					azimuth: 180
				};

				const pmremGenerator = new THREE.PMREMGenerator( base.renderer );

				function updateSun() {

					const phi = THREE.MathUtils.degToRad( 90 - parameters.elevation );
					const theta = THREE.MathUtils.degToRad( parameters.azimuth );

					sun.setFromSphericalCoords( 1, phi, theta );

					sky.material.uniforms[ 'sunPosition' ].value.copy( sun );
					water.material.uniforms[ 'sunDirection' ].value.copy( sun ).normalize();

					base.scene.environment = pmremGenerator.fromScene( sky ).texture;

				}

				updateSun();

                


                const folderSky = gui.addFolder( 'Sky' );
				folderSky.add( parameters, 'elevation', 0, 90, 0.1 ).onChange( updateSun );
				folderSky.add( parameters, 'azimuth', - 180, 180, 0.1 ).onChange( updateSun );
				folderSky.open();

				const waterUniforms = water.material.uniforms;

				const folderWater = gui.addFolder( 'Water' );
				folderWater.add( waterUniforms.distortionScale, 'value', 0, 8, 0.1 ).name( 'distortionScale' );
				folderWater.add( waterUniforms.size, 'value', 0.1, 10, 0.1 ).name( 'size' );
				folderWater.open();




                //controls limit
				// controls.maxPolarAngle = Math.PI * 0.495;
				// controls.target.set( 0, 10, 0 );
				// controls.minDistance = 40.0;
				// controls.maxDistance = 200.0;
				// controls.update();







                //选中 ， postprocessing_outline
                // postprocessing


                const geometry = new THREE.SphereGeometry( 3, 48, 24 );

				for ( let i = 0; i < 20; i ++ ) {

					const material = new THREE.MeshBasicMaterial();
					material.color.setHSL( Math.random(), 1.0, 0.3 );

					const mesh = new THREE.Mesh( geometry, material );
					mesh.position.x = Math.random() * 4 - 2;
					mesh.position.y = Math.random() * 4 - 2;
					mesh.position.z = Math.random() * 4 - 2;
					mesh.receiveShadow = true;
					mesh.castShadow = true;
					mesh.scale.multiplyScalar( Math.random() * 0.3 + 0.1 );
					base.scene.add( mesh );

				}


                const params = {
				edgeStrength: 3.0,
				edgeGlow: 0.0,
				edgeThickness: 1.0,
				pulsePeriod: 0,
				rotate: false,
				usePatternTexture: false
			};

			// Init gui


			gui.add( params, 'edgeStrength', 0.01, 10 ).onChange( function ( value ) {

				outlinePass.edgeStrength = Number( value );

			} );

			gui.add( params, 'edgeGlow', 0.0, 1 ).onChange( function ( value ) {

				outlinePass.edgeGlow = Number( value );

			} );

			gui.add( params, 'edgeThickness', 1, 4 ).onChange( function ( value ) {

				outlinePass.edgeThickness = Number( value );

			} );

			gui.add( params, 'pulsePeriod', 0.0, 5 ).onChange( function ( value ) {

				outlinePass.pulsePeriod = Number( value );

			} );

			gui.add( params, 'rotate' );

			gui.add( params, 'usePatternTexture' ).onChange( function ( value ) {

				outlinePass.usePatternTexture = value;

			} );

			function Configuration() {

				this.visibleEdgeColor = '#ffffff';
				this.hiddenEdgeColor = '#190a05';

			}

			const conf = new Configuration();

			gui.addColor( conf, 'visibleEdgeColor' ).onChange( function ( value ) {

				outlinePass.visibleEdgeColor.set( value );

			} );

			gui.addColor( conf, 'hiddenEdgeColor' ).onChange( function ( value ) {

				outlinePass.hiddenEdgeColor.set( value );

			} );


				composer = new EffectComposer( base.renderer );

                const renderPass = new RenderPass( base.scene, base.camera );
                composer.addPass( renderPass );

                outlinePass = new OutlinePass( new THREE.Vector2( window.innerWidth, window.innerHeight ), base.scene, base.camera );
                composer.addPass( outlinePass );

                const textureLoader1 = new THREE.TextureLoader();
                textureLoader1.load( '/tri_pattern.jpg', function ( texture ) {

                    outlinePass.patternTexture = texture;
                    texture.wrapS = THREE.RepeatWrapping;
                    texture.wrapT = THREE.RepeatWrapping;

                } );

                effectFXAA = new ShaderPass( FXAAShader );
                effectFXAA.uniforms[ 'resolution' ].value.set( 1 / window.innerWidth, 1 / window.innerHeight );
                composer.addPass( effectFXAA );


                base.renderer.domElement.style.touchAction = 'none';
                base.renderer.domElement.addEventListener( 'pointermove', onPointerMove );

                function onPointerMove( event ) {

                    if ( event.isPrimary === false ) return;

                    mouse.x = ( event.clientX / window.innerWidth ) * 2 - 1;
                    mouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1;

                    checkIntersection();

                }

                function addSelectedObject( object ) {

                    selectedObjects = [];
                    selectedObjects.push( object );

                }

                function checkIntersection() {

                    raycaster.setFromCamera( mouse, base.camera );

                    const intersects = raycaster.intersectObject( base.scene, true );

                    if ( intersects.length > 0 ) {

                        

                        const selectedObject = intersects[ 0 ].object;
                        addSelectedObject( selectedObject );
                        outlinePass.selectedObjects = selectedObjects;

                    } else {

                        // outlinePass.selectedObjects = [];

                    }

                }





    update()




});

function createBox(){
    const geometry = new THREE.BoxGeometry(1,1,1)
    const materail = new THREE.MeshBasicMaterial({color:0x00ff00})
    const cube = new THREE.Mesh(geometry,materail)
    base.scene.add(cube)
}

function update() {

    const elapsedTime = clock.getElapsedTime()

    planeMaterial.uniforms.uTime.value = elapsedTime
    portalLightMaterial.uniforms.uTime.value = elapsedTime
    portalLightMaterial1.uniforms.uTime.value = elapsedTime

    if(loaderTractorFlag && loaderTractorFlag1){

        mirror.position.y = Math.sin(elapsedTime)
        mirror1.position.y = Math.sin(elapsedTime)

        const r = Date.now() * 0.0005;

        mirror.position.x =  Math.cos( r );
        mirror.position.z =  Math.sin( r );
        mirror.position.y =  Math.sin( r );

        mirror.rotation.y =  Math.sin( r );

        base.camera.lookAt( mirror.position );

        //water.position.y = Math.sin(elapsedTime)
        water.material.uniforms[ 'time' ].value += 1.0 / 60.0;

       

        
    }

    

    
    

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
    composer.render();
    //controls.update()

    
    
}

function resize(){
    base.resize();
}

</script>

<template>
  
</template>

<style scoped>

</style>