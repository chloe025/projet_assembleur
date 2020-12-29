		.286
;-----------------------------------------------------------------------

SSEG		SEGMENT	STACK
			DB		32 DUP("STACK---")
SSEG		ENDS
;-----------------------------------------------------------------------

DSEG		SEGMENT

MSGJEU      db		"Nouvelle Partie$"
MSGHELP     db		"Informations$"
Aide_1		db		"Bienvenue dans l'aide$", 0DH, 0AH
Aide_2		db		"Pour retourner en arriere, appuyez sur  echap$", 0DH, 0AH
Aide_3		db		"Vous pouvez retourner en arriere a      n'importe quel moment du jeu, mais rien ne sera sauvegarde$", 0DH, 0AH
Aide_4		db		"Le morpion se joue a 2 joueurs.         Choisissez qui commence en premier avec les fleches gauche et droite$", 0DH, 0AH
Aide_5		db		"Pour jouer, choisissez votre case avec  les touches du clavier (a,z,e,q,s,d,w,x,c), puis validez avec entree$",0DH, 0AH
MSGFIN      db		"Quitter$"
WHOPLAY		db		"Qui commence en premier ?$"
FLECH       db 		"->$"
JOUEUR1		db		"Joueur 1$"
JOUEUR2		db		"Joueur 2$"
MSG_JOUEUR1	db		"Au Joueur 1 de jouer $"
MSG_JOUEUR2	db		"Au Joueur 2 de jouer $"
TOUCHES     db      "    Les touches a utiliser + entree$"
TOUCHES1    db      "      a      z      e$"
TOUCHES2    db      "      q      s      d$"
TOUCHES3    db      "      w      x      c$"
WIN_J1		db		"Le Joueur 1 a gagne la partie!$"
WIN_J2		db		"Le Joueur 2 a gagne la partie!$"
Egal		db		"Il y a egalite !$"
Again		db		"Voulez-vous rejouer ?$"
AgainQST	db		"o pour oui, n pour non$"
SCORE		db		"  SCORE  $"
SC_J1		db		" J1 : $"
SC_J2		db		" J2 : $"
VAL_SC_J1	db		0
VAL_SC_J2	db		0
CRS_MENU	db		5
CRS_JR		db		0
J1			db		0		; à partir d'ici l'initialisation ne sert à rien
J2			db		0
color		db		?
VARX		dw		85		; car pas reconnu par le pc
VARY		dw		35		; je ne sais pas pourquoi ce n'est pas pris en compte
VARSTOP		dw		10
HG 			DB		0
HM			DB		0
HD			DB		0
MG			DB		0
MM			DB		0
MD			DB		0
BG			DB		0
BM			DB		0
BD			DB		0
TAMPON 		DB		?
Lig_Haut	DB		0
Lig_Mid		DB		0
Lig_Bas		DB		0
Col_Gauche	DB		0
Col_Mid		DB		0
Col_Droite	DB		0
Diag1		DB		0
Diag2		DB		0
Nbtour		DB		0

DSEG		ENDS
;-----------------------------------------------------------------------

CSEG		SEGMENT 'CODE'
ASSUME 		CS:CSEG, DS:DSEG, ES:SSEG

;-----------------------------------------------------------------------
;Zone des Macro
AFF_FLECH Macro	;pour afficher une flèche
	MOV AH, 09H
	LEA DX,FLECH
	INT 21H
	endm

CLEAR Macro	;on nettoie l'écran
	MOV AX,0600h
	XOR CX,CX
	MOV DX,1950h
	INT 10h
	endm

CRLF MACRO	;on va à la ligne
    MOV DL,0DH
    MOV AH,02
    INT 21H
    MOV DL,0AH
    INT 21H
	ENDM
REMISE0 Macro	;pour remettre les variables à 0
	MOV HG,0		;on remets à 0 les cases
	MOV HM,0
	MOV HD,0
	MOV MG,0
	MOV MM,0
	MOV MD,0
	MOV BG,0
	MOV BM,0
	MOV BD,0
	MOV Lig_Haut,0	; à 0 les var de victoire
	MOV Lig_Mid,0
	MOV Lig_Bas,0
	MOV Col_Gauche,0
	MOV Col_Mid,0
	MOV Col_Droite,0
	MOV Diag1,0
	MOV Diag2,0
	MOV Nbtour,0	;à 0 le nombre de tours
	endm
;---------------------------Début Main--------------------------------------------	

MAIN PROC FAR
	;sauver l'adresse de retour
	PUSH DS
	PUSH 0 
	;registre
	MOV AX,DSEG
	MOV DS,AX

	;affichage video
    MOV AX,0013H
	INT 10h

; _ _ _ _ _ _ _ _ _Selection du Mode_ _ _ _ _ _ _ _ _ _ _ _
DEB:	CLEAR
		CALL menu
;on affiche la flèche sur le premier choix
	MOV AH,02H
	MOV BH,0
	MOV DH,5
	MOV DL,7
	INT 10H
	AFF_FLECH

;on fait le test pour savoir si ya une flèche
SELECT :
			MOV AH,00h		;instruction qui attends un caractère
			INT 16h
			CMP AX,4800h 	;si on appuie sur la flèche du haut
			JE FL_SEL_HAUT
		
			CMP AX,5000h	;si on appuie sur la flèche du bas
			JE FL_SEL_BAS

			CMP AX,1C0Dh	;si on appuie sur entrée
			JE VALIDER
			JMP SELECT		;si c'est autre chose on attends une sélection

; on a appuyé sur la flèche du haut
FL_SEL_HAUT :
			CLEAR			; on nettoie l'ecran avec la macro
			CALL menu		; on affiche le menu
			SUB CRS_MENU,5		; les tests
			CMP CRS_MENU,5		; si on est sur le premier choix
			JL Retfin			; on retourne sur le dernier choix
			JGE Bouge			; sinon on peut remonter

; on a appuyé sur la flèche du bas
FL_SEL_BAS : 
			CLEAR
			CALL menu
			ADD CRS_MENU,5
			CMP CRS_MENU,15		; si on est sur le dernier choix
			JG Retdeb			; on retourne sur le premier choix
			JLE Bouge			; sinon on peut descendre

Bouge :		MOV AH,02H			;la fonction pour bouger est la meme pour monter ou descendre
			MOV DH,CRS_MENU		;suffit de changer préalablement CRS_MENU
			MOV DL,7
			INT 10H
			AFF_FLECH
			JMP SELECT			; on retourne à la sélection car pas de validation

Retfin : 	MOV CRS_MENU,15
			MOV AH,02H
			MOV BH,0
			MOV DH,CRS_MENU		
			MOV DL,7
			INT 10H
			AFF_FLECH
			JMP SELECT

Retdeb : 	MOV CRS_MENU,5
			MOV AH,02H
			MOV BH,0
			MOV DH,CRS_MENU		
			MOV DL,7
			INT 10H
			AFF_FLECH
			JMP SELECT

; on a appuyé sur Entrée
VALIDER :	MOV AH,03H	;on place le curseur, BH,DH,DL sont automatiquement initialisées avec les valeurs du dessus
			INT 10H
			CMP DH,5	; si on est sur le premier choix
			JE Part_jeu	; on lance le jeu
			CMP DH,10
			JE Part_aide	; on affiche l'aide
			CMP DH,15
			JE Quit			; on quitte
			JMP SELECT

Quit :		MOV AH,0		; interruption d'arrêt
			INT 21H			; pour les fichiers .COM
; _ _ _ _ _ _ _ _ _Partie Aide_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
Part_aide :	CLEAR
			MOV AH,02H		;on affiche les msg d'aide
			MOV DH,3
			MOV DL,12
			INT 10H

			MOV AH, 09H
			LEA DX,Aide_1
			INT 21H
			CRLF
			CRLF

			MOV AH,09H
			LEA DX,Aide_2
			INT 21H
			CRLF
			CRLF
			MOV AH,09H
			LEA DX,Aide_3
			INT 21H
			CRLF
			CRLF
			MOV AH,09H
			LEA DX,Aide_4
			INT 21H
			CRLF
			CRLF
			MOV AH,09H
			LEA DX,Aide_5
			INT 21H
			
			;on attends le bouton echap
			MOV AH,00h
			INT 16h
			CMP AX,011Bh
			JE DEB
			JMP Part_aide
; _ _ _ _ _ _ _ _ _PARTIE JEU_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
Part_jeu :	CLEAR
			CALL selection_joueur
			REMISE0
			MOV VAL_SC_J1,0	;on mets à 0 le score quand l'on se retrouve dans le menu
			MOV VAL_SC_J2,0

SELECT2 :		; la sélection du joueur	
	MOV AH,00h
	INT 16h
	CMP AX,4B00h 	;si on appuie sur la flèche de gauche
	JE FL_SEL_G
	CMP AX,4D00h	;si on appuie sur la flèche de droite
	JE FL_SEL_D
	CMP AX,1C0Dh	;si on appuie sur entrée
	JE VALIDER2
	CMP AX,011Bh	;si on appuie sur echap
	JE MAIN
	JMP SELECT2		;si c'est autre chose on attends une sélection

FL_SEL_G :	CLEAR			;on bouge à droite ou gauche
			CALL selection_joueur
			MOV AH,02H					
			MOV DH,7	
			MOV DL,3
			INT 10H
			MOV CRS_JR,DL
			AFF_FLECH
			JMP SELECT2

FL_SEL_D :	CLEAR
			CALL selection_joueur
			MOV AH,02H		
			MOV DH,7	
			MOV DL,25
			INT 10H
			MOV CRS_JR,DL
			AFF_FLECH
			JMP SELECT2

VALIDER2 :	CMP CRS_JR,3	;si le curseur est sur J1
			JE PLR1			; on initialise le booléen à 1 ou 2
			CMP CRS_JR,25
			JE PLR2

PLR1 :		MOV J1,1
			MOV J2,2
			JMP AFF_JEU

PLR2 :		MOV J2,1
			MOV J1,2
			JMP AFF_JEU			


; _ _ _ __ _ _ _Affichage zone de jeu_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
AFF_JEU : 				; résolution : 320,200
	CALL Zone_jeu
	CALL Aff_joueur
	MOV TAMPON,0		;après chaque game, on remet le tampon à 0 pour pas pouvoir valider sans sélectionner
	

; on vide le buffer clavier si il reste une touche en mémoire
	mov ah,01H	;renvoie 0 si il y a un caractère
	int 16H
	jz SELECT3	; Aller à la sélection si aucun caractère n est présent
	mov ah,00h	; on lit le caractère
	int 16H	

SELECT3 :
	MOV AH,00H														
	INT 16h	
	CMP AX,011Bh	;si on appuie sur echap
	JE Part_jeu										
	CMP AL,'a'		;si on appuie sur a
	JE CASE_HG
	CMP AL,'z'		;si on appuie sur z
	JE CASE_HM
	CMP AL,'e'		;si on appuie sur e
	JE CASE_HD
	CMP AL,'q'		;si on appuie sur q
	JE CASE_MG
	CMP AL,'s'		;si on appuie sur s
	JE CASE_MM
	CMP AL,'d'		;si on appuie sur d
	JE CASE_MD
	CMP AL,'w'		;si on appuie sur w
	JE CASE_BG
	CMP AL,'x'		;si on appuie sur x
	JE CASE_BM
	CMP AL,'c'		;si on appuie sur c
	JE CASE_BD
	CMP AX,1C0Dh	;si on appuie sur Entree
	JE VALIDER3
	JMP SELECT3

	
;Les booleens : HG appartenant à J1
;					= 2, case appartenant à J2
;					= 0, case vide
;				J1  = 1, c'est à J1 de jouer
;				J2	= 2, c'est à J2 de jouer	
	
CASE_HG :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP HG,0
	JNE SELECT3
	MOV TAMPON,1	;la case HG est la case 1
	MOV VARX,130
	MOV VARY,40
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2		;si c'est J2, on va dessiner un triangle
	CALL Croix
	JMP SELECT3

CASE_HM :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP HM,0
	JNE SELECT3
	MOV TAMPON,2
	MOV VARX,180
	MOV VARY,40
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_HD :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP HD,0
	JNE SELECT3
	MOV TAMPON,3
	MOV VARX,230
	MOV VARY,40
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_MG :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP MG,0
	JNE SELECT3
	MOV TAMPON,4
	MOV VARX,130
	MOV VARY,90
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_MM :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP MM,0
	JNE SELECT3
	MOV TAMPON,5
	MOV VARX,180
	MOV VARY,90
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_MD :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP MD,0
	JNE SELECT3
	MOV TAMPON,6
	MOV VARX,230
	MOV VARY,90
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_BG :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP BG,0
	JNE SELECT3
	MOV TAMPON,7
	MOV VARX,130
	MOV VARY,140
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_BM :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP BM,0
	JNE SELECT3
	MOV TAMPON,8
	MOV VARX,180
	MOV VARY,140
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

CASE_BD :
	CLEAR
	CALL Zone_jeu
	CALL Aff_joueur
	CMP BD,0
	JNE SELECT3
	MOV TAMPON,9
	MOV VARX,230
	MOV VARY,140
	CMP J1,2		;si J1 vaut 20 , J2 est alors à 10 et c'est J2 qui joue
	JE Case_J2
	CALL Croix
	JMP SELECT3

Case_J2 :
	SUB VARX,40
	ADD VARY,30
	CALL Triangle
	JMP SELECT3

;
VALIDER3:
	CMP TAMPON,0	;si on valide sans choisir de case, retour à la sélection
	JE SELECT3
	CALL Sauv
	CLEAR
	CALL Zone_jeu
	MOV AH,02H		
	MOV DH,2
	MOV DL,8
	INT 10H
	MOV color,4		; la var de couleur est au rouge, si jamais ya une victoire

	CMP Lig_Haut,3	;si la ligne du haut vaut 3, J1 a gagné 1+1+1=3
	JE WinLH1
	CMP Lig_Haut,12	;si la ligne du haut vaut 6, J2 a gagné 2+2+2=6
	JE WinLH2

	CMP Lig_Mid,3
	JE WinLM1
	CMP Lig_Mid,12
	JE WinLM2

	CMP Lig_Bas,3
	JE WinLB1
	CMP Lig_Bas,12
	JE WinLB2

	CMP Col_Gauche,3
	JE WinCG1
	CMP Col_Gauche,12
	JE WinCG2

	CMP Col_Mid,3
	JE WinCM1
	CMP Col_Mid,12
	JE WinCM2

	CMP Col_Droite,3
	JE WinCD1
	CMP Col_Droite,12
	JE WinCD2

	CMP Diag1,3
	JE WinDiag1_J1
	CMP Diag1,12
	JE WinDiag1_J2

	CMP Diag2,3
	JE WinDiag2_J1
	CMP Diag2,12
	JE WinDiag2_J2
	
	INC Nbtour
	CMP Nbtour,9
	JE Egalite

	CMP J1,1	;si J1=1, il joue, donc ce sera à J2 de jouer
	JE PLR2
	JNE PLR1	; si J1=2, c'est à J1 de jouer
	

Egalite :	
	MOV DL,12
	INT 10H
	MOV AH, 09H
	LEA DX,Egal
	INT 21H
	JMP Fin

WinLH1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARY,60
	CALL lignes
	JMP Fin
WinLH2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARY,60
	CALL lignes
	JMP Fin

WinLM1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARY,110
	CALL lignes
	JMP Fin
WinLM2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARY,110
	CALL lignes
	JMP Fin

WinLB1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARY,160
	CALL lignes
	JMP Fin
WinLB2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARY,160
	CALL lignes
	JMP Fin

WinCG1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARX,110
	CALL colonnes
	JMP Fin
WinCG2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARX,110
	CALL colonnes
	JMP Fin

WinCM1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARX,160
	CALL colonnes
	JMP Fin
WinCM2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARX,160
	CALL colonnes
	JMP Fin

WinCD1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARX,210
	CALL colonnes
	JMP Fin
WinCD2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARX,210
	CALL colonnes
	JMP Fin

WinDiag1_J1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARX,85
	CALL diagonale1
	JMP Fin
WinDiag1_J2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARX,85
	CALL diagonale1
	JMP Fin

WinDiag2_J1 :
	MOV AH, 09H
	LEA DX,WIN_J1
	INT 21H
	MOV VARX,235
	CALL diagonale2
	JMP Fin
WinDiag2_J2 :
	MOV AH, 09H
	LEA DX,WIN_J2
	INT 21H
	MOV VARX,235
	CALL diagonale2
	JMP Fin

Fin: 
	CMP Nbtour,9
	JE PasScore
	CMP J1,1
	JNE compareJ2
	INC VAL_SC_J1
	JMP PasScore
	compareJ2:
	INC VAL_SC_J2
	PasScore:
	MOV AH,02H		;on affiche le msg pour recommencer
	MOV DH,4
	MOV DL,12
	INT 10H
	MOV AH, 09H
	LEA DX,Again
	INT 21H

	MOV AH,02H
	MOV DL,9
	MOV DH,23
	INT 10H
	MOV AH, 09H
	LEA DX,AgainQST
	INT 21H

	MOV AH,00h
	INT 16h

	CMP AL,'o'
	JE Repitte
	CMP AL,'n'
	JE DEB
	JMP Fin

Repitte:
	REMISE0
	CMP J1,1	;si J1 est en 1 à la fin, c'est lui qui a terminé
	JE PLR2		;ce sera à J2 de commencer
	JNE PLR1	;sinon ce sera à J1
;retour
	RET

;fin procédure main
	MAIN ENDP

;-----------------------LES FONCTIONS------------------------------------------
;affiche le menu principal
menu PROC
	;placement du curseur pour la sélection JEU
    MOV AH,02H
	MOV BH,0
	MOV DH,5
	MOV DL,12
	INT 10H 
	;affichage jeu
    MOV AH, 09H
	LEA DX,MSGJEU
	INT 21H

	;placement du curseur pour la sélection AIDE
    MOV AH,02H
	MOV DH,10
	MOV DL,12
	INT 10H 
	;affichage help
    MOV AH, 09H
	LEA DX,MSGHELP
	INT 21H

	;placement du curseur pour la sélection 
    MOV AH,02H
	MOV DH,15
	MOV DL,12
	INT 10H 
	;affichage fin
    MOV AH, 09H
	LEA DX,MSGFIN
	INT 21H	
	MOV DH,5
	RET
menu ENDP

;affichage du menu de la sélection du joueur
selection_joueur PROC
	MOV AH,02H
	MOV DH,3
	MOV DL,10
	INT 10H
	MOV AH,09H
	LEA DX,WHOPLAY
	INT 21H
	
	MOV AH,02H
	MOV DH,7
	MOV DL,7
	INT 10H
	MOV AH,09H
	LEA DX,JOUEUR1
	INT 21H
	MOV AH,02H
	MOV DH,7
	MOV DL,28
	INT 10H
	MOV AH,09H
	LEA DX,JOUEUR2
	INT 21H

    MOV AH,02H
	MOV DH,12
	MOV DL,8
	INT 10H
	MOV AH,09H
	LEA DX,TOUCHES
    INT 21H

    MOV AH,02H
	MOV DH,14   ; comme on change DX, on doit remettre les valeurs
	MOV DL,8
	INT 10H
    MOV AH,09H
    LEA DX,TOUCHES1
    INT 21H
    
    MOV AH,02H
	MOV DH,16
	MOV DL,8
	INT 10H
    MOV AH,09H
    LEA DX,TOUCHES2
    INT 21H
    
    MOV AH,02H
	MOV DH,18
	MOV DL,8
	INT 10H
    MOV AH,09H
    LEA DX,TOUCHES3
    INT 21H

	RET
selection_joueur ENDP

;procédure pour tracer une ligne de la zone de jeu
lignes PROC	
	MOV AH,0CH
	MOV AL,color		;couleur blanc/gris
    MOV DX,VARY		;colonne y
    MOV CX,85       ;ligne   x          
    PIX1:    
    INT 10H    
    INC CX
    CMP CX,235
    JNE PIX1
	RET
lignes ENDP

; procédure pour tracer une colonne de la zone de jeu
colonnes PROC	
	MOV AH,0CH
    MOV AL,color
    MOV DX,35
    MOV CX,VARX                     
    PIX2:    
    INT 10H    
    INC DX
    CMP DX,185
    JNE PIX2
	RET
colonnes ENDP

;procédure pour tracer une diagonale de HG à BD
diagonale1 PROC
	MOV AH,0CH
	MOV AL,color
    MOV DX,35
    MOV CX,VARX      
    PIX5:    
    INT 10H    
    INC CX
	INC DX
    CMP CX,235
    JNE PIX5
	RET
diagonale1 ENDP

;procédure pour tracer une diagonale de HD à BG
diagonale2 PROC
	MOV AH,0CH
	MOV AL,color
    MOV DX,35
    MOV CX,VARX      
    PIX9:    
    INT 10H    
    DEC CX
	INC DX
    CMP CX,85
    JNE PIX9
	RET
diagonale2 ENDP

; procédure pour tracer une croix
Croix PROC	
	MOV AH,0CH
	MOV AL,9
 	MOV DX,VARY		;colonne y
	MOV CX,VARX       ;ligne x 
	MOV VARSTOP,CX   
	SUB VARSTOP,40      
	PIX3:    
	INT 10H    
	DEC CX
 	INC DX
	CMP CX,VARSTOP
	JNE PIX3

	ADD VARSTOP,40
	MOV CX,CX
	SUB DX,40
	PIX4:    
    INT 10H    
    INC CX
	INC DX
    CMP CX,VARSTOP
    JNE PIX4

	RET
Croix ENDP

; procédure pour tracer un triangle
Triangle PROC 
	; on est sur B, et on doit aller sur C
	MOV AH,0CH
	MOV AL,10
 	MOV DX,VARY		;colonne y
	MOV CX,VARX       ;ligne x  
	MOV VARSTOP,CX
	ADD VARSTOP,40
	PIX6:    
	INT 10H    
	INC CX
	CMP CX,VARSTOP
	JNE PIX6
	; la on est en C et on doit aller chez A
	SUB VARSTOP,20
	PIX7:    
    INT 10H    
    DEC CX
	DEC DX
    CMP CX,	VARSTOP
    JNE PIX7
	; on est en A, et on doit rejoindre B
	SUB VARSTOP,20
	PIX8:    
    INT 10H    
    DEC CX
	INC DX
    CMP CX,	VARSTOP
    JNE PIX8

	RET
Triangle ENDP

;Fonction pour affichage de la zone de jeu
Zone_jeu PROC
	CLEAR
	MOV color,15
	; affichage des lignes
	MOV VARY,35		; on initialise varY à 35
	CALL lignes		; on trace la ligne
	ADD VARY,50		; incrémentation de varY pour la prochaine ligne
	CALL lignes
	ADD VARY,50
	CALL lignes
	ADD VARY,50
	CALL lignes	

	;affichage des colonnes
	MOV VARX,85		;pareil que pour la ligne, mais en colonnes
	CALL colonnes
	ADD VARX,50
	CALL colonnes
	ADD VARX,50
	CALL colonnes
	ADD VARX,50
	CALL colonnes

	;on affiche les cases déjà validées
	CMP HG,1
	JE croix1
	JNE suiv1
	croix1:
	MOV VARX,130
	MOV VARY,40
	CALL Croix
	 
	suiv1: 
	CMP HG,4
	JE trig1
	JNE suiv2
	trig1:
	MOV VARX,90
	MOV VARY,70
	CALL Triangle

	suiv2:
	CMP HM,1
	JE croix2
	JNE suiv3
	croix2:
	MOV VARX,180
	MOV VARY,40
	CALL Croix

	suiv3:
	CMP HM,4
	JE trig2
	JNE suiv4
	trig2:
	MOV VARX,140
	MOV VARY,70
	CALL Triangle

	suiv4:
	CMP HD,1
	JE croix3
	JNE suiv5
	croix3:
	MOV VARX,230
	MOV VARY,40
	CALL Croix

	suiv5:
	CMP HD,4
	JE trig3
	JNE suiv6
	trig3:
	MOV VARX,190
	MOV VARY,70
	CALL Triangle

	suiv6:
	CMP MG,1
	JE croix4
	JNE suiv7
	croix4:
	MOV VARX,130
	MOV VARY,90
	CALL Croix

	suiv7:
	CMP MG,4
	JE trig4
	JNE suiv8
	trig4:
	MOV VARX,90
	MOV VARY,120
	CALL Triangle

	suiv8:
	CMP MM,1
	JE croix5
	JNE suiv9
	croix5:
	MOV VARX,180
	MOV VARY,90
	CALL Croix

	suiv9:
	CMP MM,4
	JE trig5
	JNE suiv10
	trig5:
	MOV VARX,140
	MOV VARY,120
	CALL Triangle

	suiv10:
	CMP MD,1
	JE croix6
	JNE suiv11
	croix6:
	MOV VARX,230
	MOV VARY,90
	CALL Croix

	suiv11:
	CMP MD,4
	JE trig6
	JNE suiv12
	trig6:
	MOV VARX,190
	MOV VARY,120
	CALL Triangle

	suiv12:
	CMP BG,1
	JE croix7
	JNE suiv13
	croix7:
	MOV VARX,130
	MOV VARY,140
	CALL Croix

	suiv13:
	CMP BG,4
	JE trig7
	JNE suiv14
	trig7:
	MOV VARX,90
	MOV VARY,170
	CALL Triangle

	suiv14:
	CMP BM,1
	JE croix8
	JNE suiv15
	croix8:
	MOV VARX,180
	MOV VARY,140
	CALL Croix

	suiv15:
	CMP BM,4
	JE trig8
	JNE suiv16
	trig8:
	MOV VARX,140
	MOV VARY,170
	CALL Triangle

	suiv16:
	CMP BD,1
	JE croix9
	JNE suiv17
	croix9:
	MOV VARX,230
	MOV VARY,140
	CALL Croix

	suiv17:
	CMP BD,4
	JE trig9
	JNE suiv18
	trig9:
	MOV VARX,190
	MOV VARY,170
	CALL Triangle

	suiv18:
	RET
Zone_jeu ENDP

; pour afficher qui doit jouer
Aff_joueur PROC	
	MOV AH,02H
	MOV BH,0
	MOV DH,2
	MOV DL,12
	INT 10H
	CMP J1,1		;selon le booleen, on affiche qui doit jouer
	JE MSG_J1
	CMP J2,1
	JE MSG_J2
	MSG_J1 : 	
		MOV AH,09H
		LEA DX,MSG_JOUEUR1
		INT 21H
		JMP RETJEU
	MSG_J2 : 	
		MOV AH,09H
		LEA DX,MSG_JOUEUR2
		INT 21H
		JMP RETJEU
	RETJEU:
	CRLF		;affichage du score
	CRLF
	MOV AH,09H
	LEA DX,SCORE
	INT 21H
	CRLF
	CRLF
	MOV AH,09H			; msg du j1
	LEA DX,SC_J1
	INT 21H
	MOV DL,VAL_SC_J1	; score du j1
	ADD DL,30H
	MOV AH,02
	INT 21H

	CRLF
	MOV AH,09H			; msg du j1
	LEA DX,SC_J2
	INT 21H
	MOV DL,VAL_SC_J2	; score du j1
	ADD DL,30H
	MOV AH,02
	INT 21H
	RET
Aff_joueur ENDP

; pour garder en mémoire après la validation
Sauv PROC	

	CMP J1,1 ; si J1 joue, J1=1 et J2=2(4 pour les calculs)
	JNE val3
	MOV AL,1 ;si J1 joue, J1 vaut 1, sinon il vaut 2							
	JMP continue
	val3:
	MOV AL,4

	continue:
	CMP TAMPON,1
	JE deplac1	
	RET1:
	CMP TAMPON,2		;si on appuie sur z
	JE deplac2
	RET2:
	CMP TAMPON,3		;si on appuie sur e
	JE deplac3
	RET3:
	CMP TAMPON,4		;si on appuie sur q
	JE deplac4
	RET4:
	CMP TAMPON,5		;si on appuie sur s
	JE deplac5
	RET5:
	CMP TAMPON,6		;si on appuie sur d
	JE deplac6
	RET6:
	CMP TAMPON,7		;si on appuie sur w
	JE deplac7
	RET7:
	CMP TAMPON,8		;si on appuie sur x
	JE deplac8
	RET8:
	CMP TAMPON,9		;si on appuie sur c
	JE deplac9 
	JMP RET9
	deplac1: 	
		MOV HG,AL
		ADD Lig_Haut,AL	;pour calculer les solutions possibles
		ADD Col_Gauche,AL	
		ADD Diag1,AL
		JMP RET1
	deplac2: 
		MOV HM,AL
		ADD Lig_Haut,AL
		ADD Col_Mid,AL
		JMP RET2
	deplac3: 
		MOV HD,AL
		ADD Lig_Haut,AL
		ADD Col_Droite,AL
		ADD Diag2,AL
		JMP RET3
	deplac4:
		MOV MG,AL
		ADD Lig_Mid,AL
		ADD Col_Gauche,AL
		JMP RET4
	deplac5: 
		MOV MM,AL
		ADD Lig_Mid,AL
		ADD Col_Mid,AL
		ADD Diag1,AL
		ADD Diag2,AL
		JMP RET5
	deplac6: 
		MOV MD,AL
		ADD Lig_Mid,AL
		ADD Col_Droite,AL
		JMP RET6
	deplac7: 
		MOV BG,AL
		ADD Lig_Bas,AL
		ADD Col_Gauche,AL
		ADD Diag2,AL
		JMP RET7
	deplac8: 
		MOV BM,AL
		ADD Lig_Bas,AL
		ADD Col_Mid,AL
		JMP RET8
	deplac9: 
		MOV BD,AL
		ADD Lig_Bas,AL
		ADD Col_Droite,AL
		ADD Diag1,AL
	RET9:
	RET
Sauv ENDP
;-----------------------------------------------------------------------
; fin code du segment
	CSEG ENDS
; fin de prog
	END MAIN

;-----------------------------------------------------------------------
;SOURCES, mais il en manque quelques-unes, ce sont les majeures
;http://stanislavs.org/helppc/int_21.html
;https://www.gladir.com/LEXIQUE/INTR/int16f00.htm
;https://www.supinfo.com/cours/1CPA/chapitres/09-assembleur-x86#idm44858302451616
;https://stackoverflow.com/questions/43427609/i-am-unable-to-draw-a-circle-using-midpoint-algorithm-in-8086-assembly-with-dire/43430463#43430463
;https://asm.developpez.com/intro/