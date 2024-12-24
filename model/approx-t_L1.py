import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import sympy as sp
import numpy as np


xx, yy = sp.symbols('x y')
z = xx * yy


total_relative_error = 0  
total_square_error = 0    
total_error_distance = 0  
num_points = 0            


for x, y in [(1.5, 1.25), (1.5, 1.75)]:
    x_range = np.linspace(x - 0.5, x + 0.5, 100)
    y_range = np.linspace(y - 0.25, y + 0.25, 100)
    X, Y = np.meshgrid(x_range, y_range)

    
    dz_dx = sp.diff(z, xx)
    dz_dy = sp.diff(z, yy)

    taylor_expansion = z.subs([(xx, x), (yy, y)]) + \
                       dz_dx.subs([(xx, x), (yy, y)]) * (xx - x) + \
                       dz_dy.subs([(xx, x), (yy, y)]) * (yy - y)

    
    error_function = z - taylor_expansion

    error = np.zeros_like(X, dtype=float)
    for i in range(len(x_range)):
        for j in range(len(y_range)):
            true_value = float(z.subs({xx: x_range[i], yy: y_range[j]}))
            error_value = float(error_function.subs({xx: x_range[i], yy: y_range[j]}))
            error[i][j] = error_value

            
            if true_value != 0:  
                total_relative_error += abs(error_value / true_value)
            total_square_error += error_value ** 2
            total_error_distance += (error_value)
            num_points += 1



mean_relative_error = total_relative_error / num_points
mean_square_error = total_square_error / num_points
mean_error_distance = total_error_distance / num_points


print(f"Mean Relative Error (MRE): {mean_relative_error}")
print(f"Mean Square Error (MSE): {mean_square_error}")
print(f"Mean Error Distance (MED): {mean_error_distance}")

