library(MASS)
library(qpcR)
library(sarima)
source("spec.arma.R")
source("plot.roots.R")


setwd("/home/sxi/Shon_windows/Documents/College/PSTAT 174 Fall17/Project")
co2data <- read.table("co2_mm_mlo.txt")

colnames(co2data) <- c("year","month","decimalDate","averageCO2","interpolated","trend","days")

co2 <- co2data[315:702,]
co2.test <- co2[703:717,]

co2.ts <- ts(co2$averageCO2, start=c(1984,5),frequency=12)
#co2.ts <- ts(co2$interpolated)

par(mfrow=c(1,1))
ts.plot(co2.ts,
     xlab="Time",
     ylab="Average CO2 ",
     main="co2 over Time")

#ACF and PACF
#par(mfrow=c(1,2))
#acf(co2.ts, lag.max=20, main="ACF")
#pacf(co2.ts, lag.max=20, main="PACF")

#### BOX COX TRANSFORMATION ###

# Box-Cox transformation
par(mfrow=c(1,1))
co2.bctrans <- boxcox(co2.ts~as.numeric(1:length(co2.ts)), 
                      plotit=TRUE,
                      lambda=seq(-4,2,0.1))
lambda <- co2.bctrans$x[which(co2.bctrans$y==max(co2.bctrans$y))]
lambda
co2.bc <- (1/lambda)*(co2.ts^lambda-1)

# Plot original data vs Box-Cox transformed data
op <- par(mfrow=c(1,2))
ts.plot(co2.ts,main = "Original data",ylab = expression(X[t]))
ts.plot(co2.bc,main = "Box-Cox tranformed data", ylab = expression(Y[t]))
par(op)

# Calculate and compare variance
var(co2.ts)
var(co2.bc)

# Plot acf/pacf for box-cox transformation vs original
par(mfrow=c(2,2))
acf(co2.ts, lag.max=60, main="ACF of Original")
acf(co2.bc, lag.max=60, main="ACF of Box-Cox")

pacf(co2.ts, lag.max=60, main="PACF of Original")
pacf(co2.bc, lag.max=60, main="PACF of Box-Cox")

#Seems like transformation not needed


##### DIFFERENCING FOR SEASONALITY

# Difference at lag 12 to remove seasonality component for transformed and original data
co2.diff12 <- diff(co2.ts, lag=12)
co2.diff12.bc <- diff(co2.bc, lag=12)


# Plot ACF and PACF of original and transformed data to compare
par(mfrow=c(2,2))
acf(co2.diff12, lag.max=60, main="ACF of Original- Seasonality Removed")
acf(co2.diff12.bc, lag.max=60, main="ACF of Box-Cox - Seasonality Removed")

pacf(co2.diff12, lag.max=60, main="PACF of Original- Seasonality Removed")
pacf(co2.diff12.bc, lag.max=60, main="PACF of Box-Cox - Seasonality Removed")


'''
plot(co2.diff12,
     xlab="Time",
     ylab="co2",
     main="co2 Original - Seasonality Removed")

plot(co2.diff12.tr,
     xlab="Time",
     ylab="co2",
     main="co2 Transformed - Seasonality Removed")
'''

# Plot time series after differencing at lag 12
par(mfrow=c(1,2))
ts.plot(co2.diff12,
        xlab="Time",
        ylab="co2",
        main="co2 Original - Seasonality Removed")
ts.plot(co2.diff12.bc,
        xlab="Time",
        ylab="co2",
        main="co2 Transformed - Seasonality Removed")




##### DIFFERENCING FOR TREND

# Difference at lag=1 to remove trend component
co2.diff12_1 <- diff(co2.diff12, lag=1)
co2.diff12_1.bc <- diff(co2.diff12.bc, lag=1)

#ACF and PACF of trend and seasonality removed 
par(mfrow=c(2,2))
acf(co2.diff12_1, lag.max=60, main="ACF of Original - Seasonality and Trend Removed")
acf(co2.diff12_1.bc, lag.max=60, main="ACF of Box-Cox - Seasonality and Trend Removed")

pacf(co2.diff12_1, lag.max=60, main="PACF of Original - Seasonality and Trend Removed")
pacf(co2.diff12_1.bc, lag.max=60, main="PACF of Box-Cox - Seasonality and Trend Removed")

#Stick with original, lags between transformed and original are not significant

##### CONTINUE DIFFERENCING?

co2.diff12_1.2 <- diff(co2.diff12_1, lag=1)

var(co2.ts)
var(co2.diff12)
var(co2.diff12_1)
var(co2.diff12_1.2)

#No, no more differencing

##### IDENTIFY MODEL

# Plot time series, ACF, and PACF of original time series differenced at 12 and 1
par(mfrow=c(3,1))
ts.plot(co2.diff12_1,
        xlab="Time",
        ylab="co2",
        main="co2 Original - Seasonality and Trend Removed")
acf(co2.diff12_1, lag.max=60, main="ACF of Original - Seasonality and Trend Removed")
pacf(co2.diff12_1, lag.max=60, main="PACF of Original - Seasonality and Trend Removed")

#Time series seems stationary
#ACF significant at lag 1

#SARIMA(p,1,q)x(P,1,Q)12
#SARIMA(2,1,0)x(0,1,1)12
#SARIMA(2,1,0)x(1,1,0)12
#SARIMA(2,1,0)x(1,1,1)12
#SARIMA(2,1,0)x(2,1,1)12

#P=1,2, Q=1, P=Q=1
#p=

###### FITTING MODEL AND DIAGNOSTIC TESTING

# Fitting possibl models
fit1 <- arima(x=co2.ts, order=c(2,1,0),seasonal=list(order=c(0,1,1),period=12))
fit1
fit2 <- arima(x=co2.ts, order=c(2,1,0),seasonal=list(order=c(1,1,0),period=12))
fit2
fit3 <- arima(x=co2.ts, order=c(2,1,0),seasonal=list(order=c(1,1,1),period=12))
fit3
fit4 <- arima(x=co2.ts, order=c(2,1,0),seasonal=list(order=c(2,1,1),period=12))
fit4

# Check if models are causal and invertible
par(mfrow=c(1,1))
spec.arma(ma=c(-0.9611)) #fit1
spec.arma(ar=c(-0.3853,-0.1671,-0.4858)) #fit2
spec.arma(ar=c(-0.3350,-0.1430,0.0384),ma=c(-0.9159)) #fit3
spec.arma(ar=c(-0.3357,-0.1431,0.0429,0.0230),ma=c(-0.9212)) #fit4
#No erros occurred

plot.roots(NULL,polyroot(c(1,-0.9611)),main="roots of MA part - fit1")
plot.roots(NULL,polyroot(c(1,-0.3853,-0.1671,-0.4858)),main="roots of AR part - fit2")
plot.roots(NULL,polyroot(c(1,-0.9159)),main="roots of MA part - fit3")
plot.roots(NULL,polyroot(c(1,-0.3350,-0.1430,0.0384)),main="roots of AR part - fit3")
plot.roots(NULL,polyroot(c(1,-0.9212)),main="roots of MA part - fit4")
plot.roots(NULL,polyroot(c(1,-0.3357,-0.1431,0.0429,0.0230)),main="roots of AR part - fit4")


# Function to create matrix of AICc values
aiccs <- matrix(NA, nr =3, nc = 3)
dimnames(aiccs) = list(P=0:2, Q=0:2)
for(P in 0:2){
  for(Q in 0:2)
  {
    aiccs[P+1,Q+1] = AICc(arima(co2.ts, order = c(2,1,0), seasonal=list(order=c(P,1,Q), period=12), method="ML"))
  }
}
aiccs
#fit1 will be used because it has the lowest AIC and AICc values

par(mfrow=c(1,2))
acf(residuals(fit1),main="ACF of residuals of fit1")
pacf(residuals(fit1),main="PACF of residuals of fit1")

'''
#Concern that there are still lags outside of confidence interval
#Add nonseasonal component p=1, q=1, and p=q=1\

aiccs2 <- matrix(NA, nr =3, nc = 3)
dimnames(aiccs2) = list(p=0:2, q=0:2)
for(p in 0:2){
  for(q in 0:2)
  {
    aiccs2[p+1,q+1] = AICc(arima(co2.ts, order = c(p,1,q), seasonal=list(order=c(1,1,1), period=12), method="ML"))
  }
}
aiccs2

# Create final fit and check ACF and PACF
fitfinal <- arima(x=co2.ts, order=c(1,1,1),seasonal=list(order=c(1,1,1),period=12))
par(mfrow=c(1,2))
acf(residuals(fitfinal),main="ACF of residuals of fitfinal")
pacf(residuals(fitfinal),main="PACF of residuals of fitfinal")
'''
#fitfinal, SARIMA(2,1,0)X(0,1,1)12, is chosen model because it has lowest AIC and AICc and also has fewest parameters (theory of parsimony)

fitfinal <- arima(x=co2.ts, order=c(2,1,0),seasonal=list(order=c(0,1,1),period=12))
fitfinal

# Check if model is causal and invertible
plot.roots(NULL,polyroot(c(1,-0.9060)),main="roots of MA part")
plot.roots(NULL,polyroot(c(1,-0.3351,-0.1432)),main="roots of AR part")

spec.arma(ma=c(-0.9060),ar=c(-0.3351,-0.1432)) 

'''
# Create final fit again and check ACF and PACF
fitfinal2 <- arima(x=co2.ts, order=c(1,1,1),seasonal=list(order=c(0,1,1),period=12))
par(mfrow=c(1,2))
acf(residuals(fitfinal2),main="ACF of residuals of fitfinal")
pacf(residuals(fitfinal2),main="PACF of residuals of fitfinal")

fitfinal2

# Check if model is causal and invertible
plot.roots(NULL,polyroot(c(1,-0.5347,-0.8994)),main="roots of MA part")
plot.roots(NULL,polyroot(c(1,0.1767)),main="roots of AR part")

# Create final fit again and check ACF and PACF
fitfinal3 <- arima(x=co2.ts, order=c(0,1,2),seasonal=list(order=c(0,1,1),period=12))
par(mfrow=c(1,2))
acf(residuals(fitfinal3),main="ACF of residuals of fitfinal")
pacf(residuals(fitfinal3),main="PACF of residuals of fitfinal")

fitfinal3

# Check if model is causal and invertible
plot.roots(NULL,polyroot(c(1,-0.3595,-0.0687,-0.8993)),main="roots of MA part")
plot.roots(NULL,polyroot(c(1,0.1767)),main="roots of AR part")
'''




# Diagnostic of residuals for fitfinal
par(mfrow=c(1,1))
# Fitted residuals
ts.plot(residuals(fitfinal), main="Fitted Residuals")
# ACF and PACF
acf(residuals(fitfinal), lag.max=60, main="ACF of residuals of fit3")
pacf(residuals(fitfinal), lag.max=60, main="PACF of residuals of fit3")
# Histogram
hist(residuals(fitfinal))
# Q-Q Plot
qqnorm(residuals(fitfinal))
qqline(residuals(fitfinal),col="blue")

#sarima(co2.ts, 1,1,0,2,1,0,12) #to produce plot of p-values, acf of residuals, qq-plot

#Box-Pierce test
sqrt(length(co2$decimalDate))
Box.test(residuals(fitfinal), lag = 11, type = c("Box-Pierce"), fitdf = 2) #Box Pierce h=sqrt(388)=20

## Test for independence of residuals
Box.test(residuals(fitfinal), lag = 11, type = c("Ljung-Box"), fitdf = 2)

Box.test((residuals(fitfinal))^2, lag = 11, type = c("Ljung-Box"), fitdf = 0)

# Test for normality of residuals
shapiro.test(residuals(fitfinal))


##### FORECASTING

co2.test.ts <- ts(co2.test$averageCO2, start=c(2016,9),frequency=12)

# Predict points
index=0:14*(1/12)
futureDates=2016.66666667+index

prediction <- predict(fitfinal, n.ahead=15)
prediction$pred
prediction$se
ts.plot(co2.ts,
        xlim=c(2015,2019),
        ylim=c(395,415),
        ylab="co2",main="Forecasting for the next 15 months")
points(futureDates,prediction$pred,col="red") #plots prediction points in red
UT<-(prediction$pred+1.96*prediction$se) #calculates upper level
LT<-(prediction$pred-1.96*prediction$se) #calculates lower level
lines(futureDates,UT,lty=2, col="blue") #draws upper level in blue
lines(futureDates,LT,lty=2, col="blue") #draws lower level in blue


#To plot forecasting points with original dataset
co2All.ts <- ts(co2data[315:717,]$averageCO2, start=c(1984,5),frequency=12)

ts.plot(co2All.ts,
        xlim=c(2015,2019),
        ylim=c(395,415),
        ylab="co2",main="Original data with forecasting") #plots original uncut data
points(futureDates,prediction$pred,col="red")
lines(futureDates,UT,lty=2, col="blue")
lines(futureDates,LT,lty=2, col="blue") 

