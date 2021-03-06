(* Mathematica Test File *)

Quiet@CloseMATLAB[] (* in case the previous test file left it open *)

(* Open MATLAB and run some tests *)
Test[
	OpenMATLAB[]
	,
	Null
	,
	TestID -> "Functions-20130416-L8U1G1"
]


(* MATLAB should start up in Directory[] *)
Test[
	MFunction["pwd"][]
	,
	Directory[]
	,
	TestID -> "Functions-20130416-V5H0K2"
]

(* ----- MEvaluate -----*)

(* syntax error *)
Test[
	MEvaluate["1+"]
	,
	$Failed
	,
	{MATLink::errx}
	,
	TestID -> "Functions-20130416-K4F7D4"
]

(* runtime error *)
Test[
	MEvaluate["eig()"]
	,
	$Failed
	,
	{MATLink::errx}
	,
	TestID -> "Functions-20130520-S1J5L9"
]

(* verify that MEvaluate returns backslashes correctly *)
Test[
	StringTrim@StringTrim[MEvaluate["disp('\\backslash')"],">>"]
	,
	"\\backslash"
	,
	TestID -> "Functions-20130520-I8N9M3"
]


(* ------ MScript ------ *)

(* create a script *)
Test[
	hello = MScript["hello", "disp('Hello world!')"];
	StringMatchQ[
		StringTrim@MEvaluate[hello],
		"*Hello world!"
	]
	,
	True
	,
	TestID -> "Functions-20130416-Z1Q9P0"
]

(* test that overwrite protection is working *)
Test[
	hello = MScript["hello", "disp('Goodbye!')"]
	,
	MScript["hello"]
	,
	{MScript::owrt}
	,
	TestID -> "Functions-20130520-D6E4F1"
]

(* the original script must not be overwritten and must still be working *)
Test[
	StringMatchQ[
		StringTrim@MEvaluate[hello],
		"*Hello world!"
	]
	,
	True
	,
	TestID -> "Functions-20130416-M1G4R8"
]

(* overwrite and test again *)
Test[
	hello = MScript["hello", "disp('Goodbye!')", "Overwrite" -> True];
	StringMatchQ[
		StringTrim@MEvaluate[hello],
		"*Goodbye!"
	]
	,
	True
	,
	TestID -> "Functions-20130416-W4R6J6"
]


(* ----- MFunction ---- *)

(* Basic MFunction *)
Test[
	eig = MFunction["eig"];
	mat = N@{{1, 2}, {3, 4}};
	Reverse@Sort@Flatten[eig[mat]]
	,
	Eigenvalues[mat]
	,
	TestID -> "Functions-20130416-U6A2E2"
]

(* Two output arguments *)
Test[
	eigv = MFunction["eig", "OutputArguments" -> 2];
	mat = {{1, 0}, {0, 4}};
	eigv[mat] == {{{1., 0.}, {0., 1.}}, {{1., 0.}, {0., 4.}}}
	,
	True
	,
	TestID -> "Functions-20130416-F4W0J9"
]

(* Test error reporting when the function can't have outputs *)
Test[
	MFunction["disp"]["Hello"]
	,
	$Failed
	,
	{MATLink::errx}
	,
	TestID -> "Functions-20130416-V7Q5S2"
]

(* Test "Output" -> False: 1. throws no message 2. it executes the action *)
Test[
	MEvaluate["x=1"];
	MFunction["clear", "Output" -> False]["x"];
	MGet["x"]
	,
	$Failed
	,
	TestID -> "Functions-20130416-Q3M2M7"
]

(* TODO MFunction with user-defined function *)


(* ---- CommandWindow ---- *)

Test[
	CommandWindow["foo"]
	,
	Null
	,
	{CommandWindow::unkw}
	,
	TestID -> "Functions-20130416-W6F3R0"
]

Test[
	CommandWindow["Show"]
	,
	Null
	,
	If[$OperatingSystem === "Windows", {}, {CommandWindow::noshow}]
	,
	TestID -> "Functions-20130416-O9M5V1"
]

Test[
	CommandWindow["Hide"]
	,
	Null
	,
	If[$OperatingSystem === "Windows", {}, {CommandWindow::noshow}]
	,
	TestID -> "Functions-20130416-J0N0K0"
]

(* TODO expose C function to test if command window is visible *)


(* after all the tests have run, check that there are no
   stray handles left in the mengine process *)
Test[
	MATLink`Engine`engGetHandles[]
	,
	{}
	,
	TestID -> "Functions-20130416-F9R3O8"
]


(* check that no stray temporary variables are left
   in the MATLAB workspace *)
Test[
	Select[Flatten[{MFunction["who"][]}], StringMatchQ[#, "MATLink*"] &]
	,
	{}
	,
	TestID -> "Functions-20130416-D8F9V5"
]

Test[
	MFunction["namelengthmax"][]
	,
	63.
	,
	TestID -> "Functions-20130418-P2U0K8"
]



(* ---------------------------------------------------------------------------------------------*)

(* close MATLAB, re-open it, then re-run some of the tests *)
Test[
	CloseMATLAB[]
	,
	Null
	,
	TestID -> "Functions-20130416-A7Q3X1"
]

Test[
	OpenMATLAB[]
	,
	Null
	,
	TestID -> "Functions-20130416-M7S5E2"
]


(* the previously written script must still be alive and usable *)
Test[
	StringMatchQ[
		StringTrim@MEvaluate[hello],
		"*Goodbye!"
	]
	,
	True
	,
	TestID -> "Functions-20130416-J8O2H3"
]

(* overwrite the script *)
Test[
	hello = MScript["hello", "disp('Hello world!')", "Overwrite" -> True];
	StringMatchQ[
		StringTrim@MEvaluate[hello],
		"*Hello world!"
	]
	,
	True
	,
	TestID -> "Functions-20130416-X6T0U2"
]

(* anonymous functions *)
Test[
	add = MFunction["add2", "@(x,y)x+y"];
	add[3,4],
	7.,
	TestID -> "Functions-20130518-V0C1I2"
]

(* anonymous functions with more than 1 output *)
Test[
	eig = MFunction["myEig", "@(mat)eig(mat)","OutputArguments" -> 2];
	eig[{{1, 2}, {3, 4}}],
	{{{-0.8245648401323938`, -0.4159735579192842`}, {0.5657674649689923`, -0.9093767091321241`}}, {{-0.3722813232690143`, 0.`}, {0.`, 5.372281323269014`}}},
	TestID -> "Functions-20130518-S9B9R8"
]

(* anonymous functions with closure *)
Test[
	MEvaluate["a12345 = magic(5);"];
	MFunction["fun", "@(x)x*mean(a12345(1,:))"][2],
	26.,
	TestID -> "Functions-20130518-Y5O7H5"
]

(* check if captured value persists *)
Test[
	MFunction["fun"][3],
	39.,
	TestID -> "Functions-20130518-Z0B8Q1"
]
(* TODO crash MATLAB and re-run some tests *)
(* TODO kill mengine and re-run some tests *)