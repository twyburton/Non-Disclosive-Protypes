#' 
#' @title A scatter plot of mean values
#' @description The mean values of every point and its four closest neigbours is calculated and then plotted on a scatter plot.
#' @details Grid cells with less than 5 point are discarded to speed up calculation.
#' @param x a character, the name of the vector of values for which the mean plot is desired.
#' @param y a character, the name of the vector of values for which the mean plot is desired.
#' @param type a character, which represent the type of graph to display.
#' If \code{type} is set to 'combine', a histogram that merges the single
#' plot is displayed. Each histogram is plotted separately if If \code{type}
#' is set to 'split'.
#' @param grid.dim a numeric, the number of cells that the x-axis and y-axis are each split into. The total number of cells is grid.dim * grid.dim .
#' @param recursiveMode a logical expression for whether or not recursive mode is used during calcualtion
#' If \code{recursiveMode} is set to "TRUE", cells that contain more values than the recursive threshold will have meanPlotDS performed on them again. This significaly improves the time of the function.
#' If \code{recursiveMode} is set to "FALSE",
#' @param regression a logical expression for whether or not a regression line calculated using loess is displayed.
#' @param regression.span A numeric that controls the smoothing of the regression line.
#' @return one or more scatter plot objects and plots depending on the argument \code{type}
#' @author Burton, T.
#' @export
#' @examples {
#'
#'   # load that contains the login details
#'   data(logindata)
#'
#'   # login and assign specific variable(s)
#'   myvar <- list('LAB_TSC', 'LAB_HDL')
#'   opals <- datashield.login(logins=logindata,assign=TRUE,variables=myvar)
#'
#'   # Example 1: plot a combined meanPlot of the variables 'LAB_TSC' and 'LAB_HDL'  default behaviour
#'   ds.meanPlot(x='D$LAB_TSC', y='D$LAB_HDL')
#'
#'   # Example 2: Plot the meanPlot of LAB_TSC and LAB_HDL separately (one per study)
#'   ds.meanPlot(x='D$LAB_TSC', y='D$LAB_HDL', type='split')
#'
#'   # Example 2: plot a combined meanPlot of the variables 'LAB_TSC' and 'LAB_HDL' with recursive mode turned off
#'   ds.meanPlot(x='D$LAB_TSC', y='D$LAB_HDL', recursiveMode=FALSE)
#'
#'   # Example 3: plot a combined meanPlot of the variables 'LAB_TSC' and 'LAB_HDL' with the number of grid cells changed
#'   ds.meanPlot(x='D$LAB_TSC', y='D$LAB_HDL', grid.dim=15)
#' 
#'   # clear the Datashield R sessions and logout
#'   datashield.logout(opals)
#'
#' }
#'



ds.meanPlot <- function( x=NULL , y=NULL , type='combine', grid.dim=10 , recursiveMode=TRUE, regression=FALSE , regression.span=1 , datasources=NULL ) {

	# if no opal login details are provided look for 'opal' objects in the environment
##	if(is.null(datasources)){
##		datasources <- findLoginObjects()
##	}

	if(is.null( x )){
   		stop("Please provide the name of the column for x on the plot!", call.=FALSE)
	}

	if(is.null( y )){
   		stop("Please provide the name of the column for y on the plot!", call.=FALSE)
	}


#### SERVER CALL STUFF
	output.local <- meanPlotDS( x , y , grid.dim , recursiveMode )
#### END SERVER CALL STUFF

	if(type=="combine"){

		plot( output.local[,"x"] , output.local[,"y"], col="black" )
		print( paste( "Points Plotted: "  , nrow(output.local) ) )

		if( regression ){

			# Apply loess smoothing.
			y.loess <<- loess(y ~ x, span=regression.span, data.frame(x=output.local[,"x"] , y=output.local[,"y"]))

			# Compute loess smoothed values for all points along the curve
			y.predict <- predict(y.loess, data.frame(x=output.local[,"x"]))

			# Plot the curve.
			lines(output.local[,"x"],y.predict,col="red")
		}

	} else if(type=="split") {
    
		#ll <- length(datasources)
		#for(i in 1:ll){
		#	plot(output.local[,x] , output.local[,y], xlab = x, ylab = y, col="black")		
		#}

	} else {

		stop('Function argument "type" has to be either "combine" or "split"')

	}
}


###### TESTING ######

#data <- read.csv("O:/Documents/Data/New_HOP_Data/HOP_simulated_data.csv", header=TRUE )
#output <- ds.meanPlot( x=data$LAB_HDL , y=data$LAB_TSC , grid.dim=10 , recursiveMode=TRUE , regression=TRUE )

data <- read.csv("O:/Documents/Data/ALSPAC/ALSPAC.csv", header=TRUE )
output <- ds.meanPlot( x=data$BMI.7 , y=data$BMI.11 , grid.dim=10 , recursiveMode=TRUE, regression=TRUE, regression.span=0.8  )
