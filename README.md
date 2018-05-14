# Time Series Forecast of CO2 Emissions from Mauna Loa Volcano in Hawaii

## Abstract

The data for this project is CO2 emissions from the Mauna Loa volcano on the Island of Hawaii from 1984 to 2016. My goals are as follows:

 - Create a time series model that predicts future CO2 emissions from the Mauna Loa volcano in Hawaii
 - Have that model accurately predicted 15 months of those emissions with 95% confidence

I separated my original dataset by taking 15 months and setting them aside to test the forecasting of my model. I tried a Box-Cox transformation to see if there were any improvements that could be made with respect to variance or trend, but it was ultimately useless as the original data had no need for that transformation. The ACF and PACFs were almost identical. I did end up differencing once by lag 12 and then by lag 1 to remove seasonality and the upward trend that the data had. I identified 4 possible models and after checking their causality, invertibility, ACF, and PACF, I found my final model to be SARIMA(2,1,0) X (0,1,1)12. This final model passed every test except for the Shapiro-Wilk test, most likely due to the fact that the data wasn't normal and might have been better modeled with a long-range memory model. Despite this, I ended up forecasting 15 months of CO2 emissions and did so accurately within a 95% confidence interval.

## Introduction

My goal for this project was to create a time series model that would predict future levels of CO2 emissions from the Mauna Loa volcano on the Island of Hawaii. The dataset consists of the years, months, and decimal dates of CO2 emissions, which is expressed as parts per million (ppm) and is the number of molecules of CO2 in every one million molecules of dried air (water vapor removed). This data is extremely important as it is not only a very large dataset creted over a long period of time, but a dataset that can help us understand and predict future possible eruptions of the volcano. According to the National Oceanic and Atmospheric Administration, CO2 is the most significant volcanic gas and is greatest shortly after an eruption and then decreases exponentially over the subsequent years. Being able to predict the future levels of CO2 can assist in understanding when the next possible eruption might be. This is very important to me personally because I was born and raised in Kona on the Island of Hawaii. I spent the first 18 years of my life on Mauna Loa and have always wondered what would happen if it were to erupt. Not only does this project help me learn about my home in a new way, but it paves the path for me to use the same time series techniques to predict other sets of data back home, such as the amount of volcanic smog that gets released into the air.

I used the statistical software R and Rstudio to do my model building for this project. I followed the Box-Jenkins approach to model building and did techniques such as differencing and Box-Cox transformations. There were originally 388 months for me to model, but I used 15 to test the forecasts. I ended up using untransformed data becuase ACF and PACFs were too similar. I ended up building SARIMA
models and used the model with the lowest AIC and AICc as my final fit. I checked if my model was invertible and causal by checking if the roots were outside the unit circle and used the spec.arma function. I did the Box-Pierce test, Box-Ljung test, Mcleod-Li test, and Shapiro-Wilk test with p-values over 0.05 for all except the Shapiro-Wilk test. I ended up predicting the CO2 values accurately, as they were within teh 95% confidence interval that was part of my forecast.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure1.png?raw=true)

This Figure 1 is a time series plot of the co2 emission data. The last 15 months were removed to test the time series model. From this plot, we can see an obvious seasonal component with the steady rise and then sudden dip in emissions occurring every 12 months. There is also a very steady upward trend occurring as well. Surprisingly, the variance looks to be constant throughout the years. From this, I move on to use Box-Cox transformations to see if there is any improvements that can be made (despite it looking as though no transformation is needed).


![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure2.png)

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure3-4.png)

Figure 2 shows the confidence interval for the Box-Cox transformation. The values -0.5 and 0.5 do not fall within this confidence interval, so a log transformation or square root tranformation does not seem likely. The actual value of lambda is: -2.484848


This value was used to calculate the Box-Cox transformed data that we see in Figure 4. Looking at the transformation, it does not seem like anything has changed. The data may have straightened out slightly from 1990-2000, but the difference is miniscule and not significant. To go even furthur and be certain that a transformation is not necessary, I plotted the ACF and PACF for the Box-Cox transformed and original data.


![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure5-8.png)


Figures 5-8 are supposed to help us decide on whether or not to use the transformed data. As we can see, there is practially no change from the original to the transformed. One would think that we would decide to use the original data from here, but first, we will see how differencing in lags will affect the transformation. Based on the dataset and from looking at the plot, we can tell that there is seasonality in the data. We difference at lag 12 to remove this seasonality becuase the data is given in months. We will plot the ACF and PACF of the original and transformed data differenced at lag 12 to see if there is any change.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure9-12.png)

Once again, the purpose of Figures 9-12 are to help us determine if transformations are necessary. This time, there appears to be some change with respect to the ACF for both original and transformed data. After hitting 1 lag, the two plots change sign and value. The transformed data switched to negative values for ACF while the original stays positive. To look into this once more, we will difference again. Because there seems to be a significant lag at 1 for the PACF for both plots, we will difference at lag 1.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure13-16.png)

Figures 13-16 show the plots after differencing by lag 1 and removing the trend from the data. It is here where we conclude that we will not need to use a transformation on this data. The ACF and PACF plots area essentially the same. There are some small differences, but they are so miniscule that they are insignificant. We will move on to the next part of the project

Before we start to move on to the model portion of the project, we must decide on whether or not to keep differencing. Therefore, we will difference the original data by lag 1 one more time and check the variance of differencing we have made to see when the variance stops decreasing.

    [1] 296.0295
    [1] 0.4979442
    [1] 0.1981395
    [1] 0.5251861

We can see that at the last difference of lag 1, the variance starts to increase. Therefore, we will ignore that last difference at lag 1. The data that we will be using to identify our model is the data that is differenced by lag 12 and then by lag 1.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure17.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure18.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure19.png)

Looking at the time series plot that is differenced, it seems to be more random and stationary. The ACF and PACF plots of Figures 18 and 19 can help us interpret our model. We can see seasonal lags at factors of 12. The ACF peaks at lag 1 and PACF trails off, so we can consider P=0 and Q=1. And since both ACF and PACF are large at lag 12, we can think of P=1, Q=1, or P=Q=1. The ACF and PACF both tail off in seasonal lags, so we can consider P=2 or P=1 and Q=1. Looking within the season to choose the nonseasonal p and q, we see that PACF is mostly cut off after lag 2. Therefore, we will choose p=2 and q=0.

With this information, I have come up with the following models:

SARIMA(2,1,0) X (0,1,1)12  
SARIMA(2,1,0) X (1,1,0)12  
SARIMA(2,1,0) X (1,1,1)12  
SARIMA(2,1,0) X (2,1,1)12  
 
Now, we will move on to fitting the models and diagnostic checking.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/modelfit1.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/modelfit2.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/modelfit3.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/modelfit4.png)

After using the arima function on the models, we can see that fit1 has the lowest AIC value. Before continuing, however, we must check to make sure the models we just created are both causal and invertable. We do this two ways - by making sure the roots are outside of the unit circle and that the spec.arma function does not return a warning.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure20-21.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure22-23.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure24-25.png)

We can see in Figures 20-25 that the roots of the polynomials for the AR and MA parts of the model are all outside of the unit circle. It also turns out that the spec.arma function did not return any errors, thus solidifying the fact that theses models are causal and invertible.

Now that we know our models are causal and invertible, we can look for the models with the lowest AICc values and use that with the knowledge of the model with the lowest AIC value to choose our final model.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/modelchoose.png)

When P=0 and Q=1, we get the lowest AICc value. This corresponds with fit1, which also has the lowest AIC value. Fit1 also happens to be tied for having the fewest parameters, which goes along with the theory of parsimony (choosing the model with the fewest parameters). These findings lead us to choose fit1 as our final model.

Moving forward, we just want to double check to make sure that our final model is causal and invertible.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/finalmodelcheck.png)

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure26-27.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure28.png)

We see from Figures 26-28 that our model is ready to go and it is now time for diagnostic testing.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure29.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure30.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure31.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure32.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure33.png)

In Figures 29-33, we are analyzing the residuals of our model. Our time series data looks random and stationary, which is what we want it to look like. Our ACF and PACF have essentially no significant lags after 0, with the exception of lag 3. However, that lag is close enough to the edge of the confidence interval to where we can consider it insignificant. The Histogram is slightly concerning, as it has a small skew to it. This could possibl be from outliers and have an effect on the symmetry of the data. The Q-Q Plot also seems to be a little bit off around the tails of the plot. Taking this into consideration, we will consider this model satisfactory and proceed forward with the understanding that there may possibly be errors when it comes to normality and symmetry.


Now we will move on to the tests for diagnostic checking.


![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/diagnosticcheck1.png)
![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/diagnosticcheck2.png)

Here, we run the Box-Pierce test, Box-Ljung test, Mcleod-Li test, and Shapiro-Wilk test. The p-values for all but one test ended up being greater than 0.05, thus failing to reject the null hypotheses. The lag for these tests was found by calculating sqrt(n) = sqrt(338) = 19.697 = 20. The number of fitted parameters is 2 because p=2 and q=0.

Since the p-value for the Box-Pierce and Box-Ljung tests were greater than 0.05, it tells us that the autocorrelations are 0 up to 11. The p-value for the Mcleod-li test being greater than 0.05 tells us that the residuals are independent. The p-value for the Shapiro-Wilk test is less than 0.05, which indicates a rejection of the assumption of normality. This makes sense looking back at the histogram and Q-Q plot. However, I will continue on with this model cautiously.

Our best model is:  SARIMA(2,1,0) X (0,1,1)12


Now we move on to forecasting. I am attempting to forecast the first 15 months after August 2016 using the model above. Using the predict function, I am able to calculate the predicted co2 levels and the upper and lower bounds associated with them. Using the standard error from the predict function, I am able to create a confidence interval for the predicted points.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure34.png)

Here, in Figure 34, we have our predicted co2 levels for the first 15 months after August 2016 and the confidence interval for them. We thankfully see that all of our points fall withing the confidence interval. Adding on the actual co2 levels from the data we took out from the beginning, we can see how well our model held up.

![](https://github.com/Inouyesan/TImeSeries_MaunaLoaCO2_R/blob/master/images/figure35.png)

Now that our actual data is plotted along with our predicted values, we can see that our model held up pretty well. At the end of 2016, the actual values of co2 emissions approaches the upper bound of the confidence interval, but then moves back towards the middle soon into 2017. We also see that our predicted values trail right underneith the actual values of co2 over the 15 months.

## Conclusion

My goal was to create a time series model to predict future values of co2 emissions for 15 months. Using the Box-Jenkings methodology, I was able to analyze my data to create a the following time series model:
      SARIMA(2,1,0) X (0,1,1)12

I ultimately achieved what I set out to do. I created a time series model that predicted future co2 emissions from the Mauna Loa volcano in Hawaii and my model accurately predicted 15 months of those emissions with 95% confidence. I would like to thank Professor Feldman and my TA, Zhipu Zhou, for teaching me the tools needed to accomplish this project.    

## References
 - https://www.esrl.noaa.gov/gmd/ccgg/trends/data.html
