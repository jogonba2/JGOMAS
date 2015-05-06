debug(3).

// Name of the manager
manager("Manager").

// Team of troop.
team("AXIS").
// Type of troop.
type("CLASS_SOLDIER").

// Value of "closeness" to the Flag, when patrolling in defense
patrollingRadius(8).




{ include("jgomas.asl") }


// Plans


/*******************************
*
* Actions definitions
*
*******************************/

/////////////////////////////////
//  GET AGENT TO AIM
/////////////////////////////////
/**
 * Calculates if there is an enemy at sight.
 *
 * This plan scans the list <tt> m_FOVObjects</tt> (objects in the Field
 * Of View of the agent) looking for an enemy. If an enemy agent is found, a
 * value of aimed("true") is returned. Note that there is no criterion (proximity, etc.) for the
 * enemy found. Otherwise, the return value is aimed("false")
 *
 * <em> It's very useful to overload this plan. </em>
 * 
 */
+!get_agent_to_aim
    <-  ?debug(Mode); if (Mode<=2) { .println("Looking for agents to aim."); }
        ?fovObjects(FOVObjects);
        .length(FOVObjects, Length);
        
        ?debug(Mode); if (Mode<=1) { .println("El numero de objetos es:", Length); }
        
        if (Length > 0) {
		    +bucle(0);
    
            -+aimed("false");
    
            while (aimed("false") & bucle(X) & (X < Length)) {
  
                //.println("En el bucle, y X vale:", X);
                
                .nth(X, FOVObjects, Object);
                // Object structure 
                // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
                .nth(2, Object, Type);
                
                ?debug(Mode); if (Mode<=2) { .println("Objeto Analizado: ", Object); }
                
                if (Type > 1000) {
                    ?debug(Mode); if (Mode<=2) { .println("I found some object."); }
                } else {
                    // Object may be an enemy
                    .nth(1, Object, Team);
                    ?my_formattedTeam(MyTeam);
          
                    if (Team == 100) {  // Only if I'm AXIS
				
 					    ?debug(Mode); if (Mode<=2) { .println("Aiming an enemy. . .", MyTeam, " ", .number(MyTeam) , " ", Team, " ", .number(Team)); }
					    //+aimed_agent(Object);
                        //-+aimed("true");

                    }
                    
                }
             
                -+bucle(X+1);
                
            }
                     
       
        }

     -bucle(_).

        

/////////////////////////////////
//  LOOK RESPONSE
/////////////////////////////////
+look_response(FOVObjects)[source(M)]
    <-  //-waiting_look_response;
        .length(FOVObjects, Length);
        if (Length > 0) {
            ///?debug(Mode); if (Mode<=1) { .println("HAY ", Length, " OBJETOS A MI ALREDEDOR:\n", FOVObjects); }
        };    
        -look_response(_)[source(M)];
        -+fovObjects(FOVObjects);
        //.//;
        !look.
      
        
/////////////////////////////////
//  PERFORM ACTIONS
/////////////////////////////////
/**
 * Action to do when agent has an enemy at sight.
 *
 * This plan is called when agent has looked and has found an enemy,
 * calculating (in agreement to the enemy position) the new direction where
 * is aiming.
 *
 *  It's very useful to overload this plan.
 * 
 */

+!perform_aim_action
    <-  // Aimed agents have the following format:
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        ?aimed_agent(AimedAgent);
        ?debug(Mode); if (Mode<=1) { .println("AimedAgent ", AimedAgent); }
        .nth(1, AimedAgent, AimedAgentTeam);
        ?debug(Mode); if (Mode<=2) { .println("BAJO EL PUNTO DE MIRA TENGO A ALGUIEN DEL EQUIPO ", AimedAgentTeam); }
        ?my_formattedTeam(MyTeam);


        if (AimedAgentTeam == 100) {
        
            .nth(6, AimedAgent, NewDestination);
            ?debug(Mode); if (Mode<=1) { .println("NUEVO DESTINO MARCADO: ", NewDestination); }
            //update_destination(NewDestination);
        }
        .
    
/**
 * Action to do when the agent is looking at.
 *
 * This plan is called just after Look method has ended.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
 
 
/* ESTE PLAN HE TOCADO!!!! */
+!perform_look_action <-
?fovObjects(FOVObjects);
	.length(FOVObjects, Length);
    +bucle(0); 
    .my_name(ME);
    ?vez(VEZ);
    ENEMIGOSVISTOS  = [];
    -+bandera(false);
    ?no_vista(NOVISTA);
    while (bucle(X) & (X < Length)) {
        .nth(X, FOVObjects, Object);
        // Object structure
        // [#, TEAM, TYPE, ANGLE, DISTANCE, HEALTH, POSITION ]
        .nth(2, Object, Type);   
        .nth(1, Object, Team);           
        if (Type>1000) {
            if(Type==1003){
				-+bandera(true);
                .nth(6,Object,POSBANDERA); // Ya tiene la pos de la bandera //
                -+POSBANDERA;
                ?pos(POSBANDERAX,POSBANDERAY,POSBANDERAZ);
                if(VEZ==1){
				    +pos_bandera_original(POSBANDERAX,POSBANDERAY,POSBANDERAZ);
				    -+vez(2);
				}else{ -+no_vista(0); }
            }	   
        }else{
			if(Team==100){
				.concat(ENEMIGOSVISTOS,[Object],ENEMIGOSVISTOS2);			
			}
		}
        -+bucle(X+1);         
    } 
    ?bandera(BANDERA);
    if(BANDERA==false & VEZ==2 & NOVISTA<12){ // Si no se ha superado un umbral de veces no vista la bandera //
        -+no_vista(NOVISTA+1);
    }
    if(NOVISTA>=12){
		.println("BANDERA ROBADA!!");
		// Ver el enemigo mas cercano y si lo hay ir a por el, si no, hacer el mayor patrolling posible //
		//.length(ENEMIGOSVISTOS2,LengthEnemigos);
		//.println("ENEMIGOS VISTOS:" , LengthEnemigos);
		//if(LengthEnemigos>0){
			//-+tasks([]);
			//!nearest(ENEMIGOSVISTOS2,LengthEnemigos);
			//?nearest(Enemigo,EnemigoPosition,EnemigoDistance);
			//.println("Yendo a por el enemigo mas lejano");
			//!add_task(task(3000,"TASK_GOTO_ENEMIGO",EnemigoPosition,""));		
		//}
		//else{
			// O desplazarse aleatoriamente por el mapa //
			//.random(RandomX,230);
			//.random(RandomZ,230);
			//!safe_pos(RandomX,0,RandomZ);
			//?safe_pos(SafeX,0,SafeZ);
			//!add_task(task(3000,"TASK_GOTO_ALEATORIO",pos(SafeX,0,SafeZ),""));
			-+patrollingRadius(64);
		//}
	}
	
-bucle(_).

+!perform_no_ammo_action .
/// <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_NO_AMMO_ACTION GOES HERE.") }.

/**
 * Action to do when an agent is being shot.
 *
 * This plan is called every time this agent receives a messager from
 * agent Manager informing it is being shot.
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!perform_injury_action .
///<- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_INJURY_ACTION GOES HERE.") }.


/////////////////////////////////
//  SETUP PRIORITIES
/////////////////////////////////
/**  You can change initial priorities if you want to change the behaviour of each agent  **/
+!setup_priorities
    <-  +task_priority("TASK_NONE",0);
        +task_priority("TASK_GIVE_MEDICPAKS", 2000);
        +task_priority("TASK_GIVE_AMMOPAKS", 0);
        +task_priority("TASK_GIVE_BACKUP", 0);
        +task_priority("TASK_GET_OBJECTIVE",1000);
        +task_priority("TASK_ATTACK", 1000);
        +task_priority("TASK_RUN_AWAY", 1500);
        +task_priority("TASK_GOTO_POSITION", 750);
        +task_priority("TASK_PATROLLING", 500);
        +task_priority("TASK_WALKING_PATH", 750).   



/////////////////////////////////
//  UPDATE TARGETS
/////////////////////////////////
/**
 * Action to do when an agent is thinking about what to do.
 *
 * This plan is called at the beginning of the state "standing"
 * The user can add or eliminate targets adding or removing tasks or changing priorities
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!update_targets 
	<-	?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR UPDATE_TARGETS GOES HERE.") }.
	
/////////////////////////////////
//  CHECK MEDIC ACTION (ONLY MEDICS)
/////////////////////////////////
/**
 * Action to do when a medic agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkMedicAction
<-  -+medicAction(on).
// go to help


/////////////////////////////////
//  CHECK FIELDOPS ACTION (ONLY FIELDOPS)
/////////////////////////////////
/**
 * Action to do when a fieldops agent is thinking about what to do if other agent needs help.
 *
 * By default always go to help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!checkAmmoAction
<-  -+fieldopsAction(on).
//  go to help



/////////////////////////////////
//  PERFORM_TRESHOLD_ACTION
/////////////////////////////////
/**
 * Action to do when an agent has a problem with its ammo or health.
 *
 * By default always calls for help
 *
 * <em> It's very useful to overload this plan. </em>
 *
 */
+!performThresholdAction
       <-
       
       ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR PERFORM_TRESHOLD_ACTION GOES HERE.") }
       
       ?my_ammo_threshold(At);
       ?my_ammo(Ar);
       
       if (Ar <= At) { 
          ?my_position(X, Y, Z);
          
         .my_team("fieldops_AXIS", E1);
         //.println("Mi equipo intendencia: ", E1 );
         .concat("cfa(",X, ", ", Y, ", ", Z, ", ", Ar, ")", Content1);
         .send_msg_with_conversation_id(E1, tell, Content1, "CFA");
       
       
       }
       
       ?my_health_threshold(Ht);
       ?my_health(Hr);
       
       if (Hr <= Ht) {  
          ?my_position(X, Y, Z);
          
         .my_team("medic_AXIS", E2);
         //.println("Mi equipo medico: ", E2 );
         .concat("cfm(",X, ", ", Y, ", ", Z, ", ", Hr, ")", Content2);
         .send_msg_with_conversation_id(E2, tell, Content2, "CFM");

       }
       .
       
/////////////////////////////////
//  ANSWER_ACTION_CFM_OR_CFA
/////////////////////////////////

   
    
+cfm_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_agree GOES HERE.")};
      -cfm_agree.  

+cfa_agree[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_agree GOES HERE.")};
      -cfa_agree.  

+cfm_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfm_refuse GOES HERE.")};
      -cfm_refuse.  

+cfa_refuse[source(M)]
   <- ?debug(Mode); if (Mode<=1) { .println("YOUR CODE FOR cfa_refuse GOES HERE.")};
      -cfa_refuse.  



/////////////////////////////////
//  Initialize variables
/////////////////////////////////

+!init
   <-  +bandera(true);
	   +no_vista(0);
	   +vez(1). 