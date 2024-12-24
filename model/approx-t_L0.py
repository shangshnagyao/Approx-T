import sympy as sp
import matplotlib.pyplot as plt
import numpy as np

x, y = sp.symbols('x y')
z = x * y

a = 1.5
b = 1.5


dz_dx = sp.diff(z, x)
dz_dy = sp.diff(z, y)


taylor_expansion = z.subs([(x, a), (y, b)]) + \
                   dz_dx.subs([(x, a), (y, b)]) * (x - a) + \
                   dz_dy.subs([(x, a), (y, b)]) * (y - b)


real_function = x * y


error_function = real_function - taylor_expansion


x_range = np.linspace(1, 2, 100)  
y_range = np.linspace(1, 2, 100) 
X, Y = np.meshgrid(x_range, y_range)


total_relative_error = 0  
total_square_error = 0    
total_error_distance = 0  
num_points = 0            


error = np.zeros_like(X, dtype=float)
for i in range(len(x_range)):
    for j in range(len(y_range)):
        true_value = float(real_function.subs({x: x_range[i], y: y_range[j]}))
        error_value = float(error_function.subs({x: x_range[i], y: y_range[j]}))
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


