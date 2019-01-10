The zip-file contains 16 codes and 2 datasets. Three operator-based models are employed: Preisach, Prandtl-Ishlinksii (PI) and Krasnosel'skii-Prokovkii (KP). For every model there are five Mathworks Matlab codes. First, a function that constructs the operator (Relay, Backlash or KP operator). The other four codes are dedicated to fitting single & butterfly loops and predicting single & butterfly loops. Furthermore, a Wolfram Mathematica code is added for an interactive response to the weighted Preisach density plane boundary. 

Content:
Matlab:
1a) Relays.m
1b) PreisachSingle.m
1c) PreisachSinglePred.m
1d) PreisachButterfly.m
1e) PreisachButterflyPred.m

2a) Backlash.m
2b) PISingle.m
2c) PISinglePred.m
2d) PIButterfly.m
2e) PIButterflyPred.m

3a) KPoperator.m
3b) KPSingle.m
3c) KPSinglePred.m
3d) KPButterfly.m
3e) KPButterflyPred.m

4) MeasurementData.mat  (single loop data)
5) Serie1.mat		(butterfly loop data)

Mathematica:
6) ButterflyPreisachPlane.nb

1a, 2a, 3a:
Operator construction functions 1a, 2a and 3a are called in the other codes. They construct the operators according to the concerning model. After the initial operator construction, the construction is repeated once more with Operator(t_1) = Operator(t_end) to eliminate the dependence on initial conditions. Codes 1a and 3a are similar in that they transform a 3D operator matrix (R, Kp) with 2D index (respectively (alpha, beta) and (rho_1, rho_2)) into a 2D matrix (R2D, Kp2D) with a 1D index for computational convenience. A shifting operator is added to the 2D operator matrix. Furthermore, both 1a and 3a have an operator plot display option that can be uncommented. Only use this option for a low M! Higher discretizations will result in many operator plots, potentially crashing Matlab. 

Backlash construction code 2a is somewhat more complicated. First, M backlash operators are constructed twice as before. Then, 2M asymmetrical operators are constructed. Fl is the matrix with LHS operators, Fr the matrix with RHS operators. Fl and Fr are both [2MxN] (sample size) sized matrices where Fl(odd) = 0 and Fr(even) = 0; The two half-empty matrices are added together to form a [2MxN] sized matrix Fas that holds all the asymmetrical operators. Furthermore, a shifting operator is added. For minor loop purposes, all the operators that exist outside the input range are set to be zero.

1b, 1d:
Codes 1b and 1d vary only in the data they load (resp. single loop and butterfly data). First, input the desired level of discretization M. The codes then start by constructing an [1xM+1] alphabeta vector. Since beta(n) = alpha(n-1), we can put both switching parameters in one vector: alphabeta(1) is now beta(1), alphabeta(2) = beta(2) = alpha(1) ... alphabeta(M+1) = alpha(M). Next, the Relay function 1a is called. Both the 3D and the 2D relay matrix are saved (the 3D matrix is used for display purposes). Then, the least squares and the SVD method are used to determine the density [(M^2+M)/2 x 1] vector p. The error between experimental data and p*R2D is calculated. Finally, p is transformed to [M+1 x M+1] sized p2D for display purposes and the fit, the operator composition and the density plane are plotted.

1c, 1e:
Codes 1c and 1e vary only in the data they load and the plot ranges. First, input the desired level of discretization M, select from which data the density plane is identified (v, dis) and select the data that is predicted using the identified density plane (v_pred, dis_pred). The density vector p is then calculated as described under the previous section. To predict the minor loops, the relays are constructed again with the minor loop input v_pred. The predicted output is now simply given by the identified weights multiplied by their corresponding minor loop relays. Finally, the predicted output is shifted such that y_pred(1) = 0 (in accordance with the experimental data) and the goodness of fit is plotted.


2b, 2d:
Input the data to be fitted and a level of discretization M. The PI fitting codes start by creating a vector with the M different operator bandwidths. After this, Backlash construction code 2a is called and creates M different backlash operators (F) and a matrix with 2M asymmetric operators (Fas). The code continues to identify the data by a least squares approach using F, so make sure that the line F=Fas (line 20) is uncommented for the asymmetrical case. After identification, the results are presented in a plot of the fit, the operator composition and the density vector. 

2c, 2e:
Codes 2c and 2e vary only in the data they load and the plot ranges. First, input the desired level of discretization M, select from which data the density plane is identified (v, dis) and select the data that is predicted using the identified density plane (v_pred, dis_pred). The density vector p is then calculated by the least squares method. To predict the minor loops, the relays are constructed again with the minor loop input v_pred. The predicted output is now simply given by the identified weights multiplied by their corresponding minor loop relays. Finally, the predicted output is shifted such that y_pred(1) = 0 (in accordance with the experimental data) and the goodness of fit is plotted.


3b, 3c, 3d, 3e:
The KP codes structure is very similar to the Preisach codes structure (1b, 1c, 1d, 1e), but it calls a different operator function (3a instead of 1a) and uses parameter vector rho instead of alphabeta. 

6:
Here, boundary B is a linear curve perpendicular to the alpha=beta line. The location of the boundary B can be adapted by changing b. The negative weights are located above the boundary, the positive weights below. The absolute value of both weights can be set in a range from 0-10. Click 'new settings' after every setting change. Finally, click on the plus-sign next to parameter x, set the autorun direction to 'forward and backward' and press play. The corresponding hysteresis loop is now constructed. 
