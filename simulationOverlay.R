library(MASS)     # library for Multivariate Normal Distribution

noiseScatter <- function( Table , xCol , yCol ){
	# Set seed for RNG
	set.seed(83)

		# Demetris Simulation

		D1a <- subset(Table, Table$PM_BMI_CONTINUOUS < 999)
		D1b <- subset(D1a, D1a$LAB_GLUC_FASTING < 99)
		D1c <- subset(D1b, D1b$LAB_HDL < 99)
		D1d <- subset(D1c, D1c$LAB_TRIG < 99)
		D1e <- subset(D1d, D1d$LAB_TSC < 99)
		D1f <- subset(D1e, D1e$GENDER < 9)
		D1g <- subset(D1f, D1f$DIS_DIAB < 9)
		D1h <- subset(D1g, D1g$DIS_CVA < 9)
		D1i <- subset(D1h, D1h$DIS_AMI < 9)

		D1 <- D1i

		# Create a subset of the Table that includes only the columns PM_BMI_CONTINUOUS, LAB_GLUC_FASTING, LAB_HDL, LAB_TRIG, GENDER, LAB_TSC
		D2 <- D1[-c(1:4,6:11,13,16:24,26:60,62:100),]

		# Find the Variance-Covariance Matrix
		VarCovMat <- cov(D2)

		# Find the Mean of each variable
		mu <- colMeans(D2)

		# Produce a sample of n random continuous variables that follow the Multivariate Normal Distribution
		n <- 10000  # Define the size of simulated data
		ContVar <- data.frame(mvrnorm(n, mu, Sigma = matrix(VarCovMat, ncol(D2), ncol(D2))))

		MP <- as.data.frame(table(D2$GENDER)[1])/(as.data.frame(table(D2$GENDER)[1])+as.data.frame(table(D2$GENDER)[2]))  # Calculate the percentage of males in the original "clean" data
		MP2 <- round(MP*n)
		GENDER_sorted <- sort(ContVar$GENDER, decreasing = FALSE)
		Th <- GENDER_sorted[MP2[1,1]]

		ContVar$GENDER <- ifelse(ContVar$GENDER > Th, 1, 0)  # replace the continuous values of gender with categorical values (0 and 1) but keep the same proportions as in the original "clean" data 

		# Do logistic regression for each discrete variable
		s1 <- glm(D1$DIS_DIAB ~ D1$LAB_TSC + D1$LAB_TRIG + D1$LAB_HDL + D1$LAB_GLUC_FASTING  + D1$PM_BMI_CONTINUOUS + D1$GENDER, family=binomial)
		v1 <- s1$coefficients[1] + s1$coefficients[2]*ContVar$LAB_TSC + s1$coefficients[3]*ContVar$LAB_TRIG + s1$coefficients[4]*ContVar$LAB_HDL + s1$coefficients[5]*ContVar$LAB_GLUC_FASTING  + s1$coefficients[6]*ContVar$PM_BMI_CONTINUOUS + s1$coefficients[7]*ContVar$GENDER
		fp1 <- exp(v1)/(1+exp(v1))  # calculate the log odds 
		DIS_DIAB <- rbinom(n,1,fp1)

		s2 <- glm(D1$DIS_CVA ~ D1$LAB_TSC + D1$LAB_TRIG + D1$LAB_HDL + D1$LAB_GLUC_FASTING  + D1$PM_BMI_CONTINUOUS + D1$GENDER, family=binomial)
		v2 <- s2$coefficients[1] + s2$coefficients[2]*ContVar$LAB_TSC + s2$coefficients[3]*ContVar$LAB_TRIG + s2$coefficients[4]*ContVar$LAB_HDL + s2$coefficients[5]*ContVar$LAB_GLUC_FASTING  + s2$coefficients[6]*ContVar$PM_BMI_CONTINUOUS + s2$coefficients[7]*ContVar$GENDER
		fp2 <- exp(v2)/(1+exp(v2))  # calculate the log odds
		DIS_CVA <- rbinom(n,1,fp2)

		s3 <- glm(D1$DIS_AMI ~ D1$LAB_TSC + D1$LAB_TRIG + D1$LAB_HDL + D1$LAB_GLUC_FASTING  + D1$PM_BMI_CONTINUOUS + D1$GENDER, family=binomial)
		v3 <- s3$coefficients[1] + s3$coefficients[2]*ContVar$LAB_TSC + s3$coefficients[3]*ContVar$LAB_TRIG + s3$coefficients[4]*ContVar$LAB_HDL + s3$coefficients[5]*ContVar$LAB_GLUC_FASTING  + s3$coefficients[6]*ContVar$PM_BMI_CONTINUOUS + s3$coefficients[7]*ContVar$GENDER
		fp3 <- exp(v3)/(1+exp(v3))  # calculate the log odds
		DIS_AMI <- rbinom(n,1,fp3)

		PM_BMI_CATERGORIAL <- ifelse(ContVar$PM_BMI_CONTINUOUS < 25, 1, ifelse(ContVar$PM_BMI_CONTINUOUS >30, 3, 2))
		
		# Combine the continuous and the discrete variables 
		synthetic_data <- cbind(ContVar,DIS_CVA,DIS_DIAB,DIS_AMI,PM_BMI_CATERGORIAL)


	plot( synthetic_data[,xCol] , synthetic_data[,yCol], xlab = xCol, ylab = yCol )
	points( Table[,xCol] , Table[,yCol], xlab = xCol, ylab = yCol, col = "red")
}




raw_data <- read.csv("O:\\\\Documents\\Data\\New_HOP_Data\\HOP_simulated_data.csv", header=TRUE )  # read csv file 

noiseScatter( raw_data, "PM_BMI_CONTINUOUS" , "LAB_HDL" )
