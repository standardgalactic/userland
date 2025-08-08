import numpy as np
import matplotlib.pyplot as plt
from scipy.integrate import odeint

# Parameters
D, lambda_, gamma, delta, eta = 1.0, 0.1, 0.1, 0.1, 0.01
sigma_phi, sigma_v, sigma_s = 0.05, 0.05, 0.05
dt, T = 0.01, 1.0
N = int(T / dt)
x = np.linspace(0, 1, 100)

# Initial conditions
Phi = np.ones_like(x)
v = np.zeros_like(x)
S = np.zeros_like(x)

# SPDE drift terms
def drift(state, t):
    Phi, v, S = state.reshape(3, -1)
    dPhi = D * np.gradient(np.gradient(Phi, x), x) - v * np.gradient(Phi, x) + lambda_ * S
    dv = -np.gradient(S, x) + gamma * Phi * v
    dS = delta * np.gradient(v, x) - eta * S**2
    return np.vstack([dPhi, dv, dS]).ravel()

# Simulate (deterministic approximation)
state0 = np.vstack([Phi, v, S]).ravel()
t = np.linspace(0, T, N)
states = odeint(drift, state0, t)
Phi_t, v_t, S_t = states[:, :100], states[:, 100:200], states[:, 200:]

# Plot
plt.figure(figsize=(10, 6))
for i in range(0, N, N//5):
    plt.plot(x, Phi_t[i], label=f'Phi at t={t[i]:.2f}')
plt.legend()
plt.savefig('phi_field.png')
plt.close()