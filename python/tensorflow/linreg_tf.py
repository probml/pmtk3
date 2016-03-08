# 1d linear regression in TF
# Builds on linreg_1d_sgd_demo

import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
import os



'''
losses = [] # store loss at each iteration
training_steps = 50
lr = 0.002


with tf.Session() as sess:
  #X = tf.constant(x_with_bias, name="input")
  #ytrue = tf.constant(np.transpose([y]).astype(np.float32), name="target")
  X  = tf.placeholder(tf.float32, [None, D])
  ytrue = tf.placeholder(tf.float32, [None, 1])
  weights = tf.Variable(tf.random_normal([2, 1], 0, 0.1), name="weights")

  tf.initialize_all_variables().run()
 
  yhat = tf.matmul(input, weights)
  yerror = tf.sub(yhat, ytrue)
  
  loss = 0.5 * tf.reduce_sum(tf.mul(yerror, yerror))
  #loss = tf.reduce_mean(tf.nn.l2_loss(yerror))
  
  # gradient = sum_n x(:,n) * yerr(n)
  # input is N*D, yerror is N*1
  # tf.mul(input, yerror) is ELEMENTWISE multiplication. TF broadcasts yerror
  # to shape N*D first. We then transpose this to D*N, and sum along the N axis,
  # to give a D*1 vector.
  gradient = tf.reduce_sum(tf.transpose(tf.mul(X, yerror)), 1, keep_dims=True)
  #gradient = tf.gradients(loss, weights)
  update_weights = tf.assign_sub(weights, lr * gradient)
  #update_weights =  tf.GradientDescent(weights, gradient, lr)  
  #update_weights = tf.train.GradientDescentOptimizer(learning_rate).minimize(loss)
  #update_weights = tf.train.AdamOptimizer(lr).minimize(loss)
  
  # Repeatedly run the graph
  iter = 0
  for _ in range(training_steps):
    sess.run(update_weights, {X: x_with_bias, ytrue: y})
    if iter % 10 == 0:
      print "iteration {1} loss {2}".format(iter, loss.eval())
    losses.append(loss.eval())

print "Finished {} iterations".format(training_steps)
coef = weights.eval()
plot_data_and_pred(x, y, coef)
plot_loss(losses)
'''