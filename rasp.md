# Лабораторная работа №3.2. Обнаружение отказов в распределенной системе

**Студент:** Войнова Екатерина

**Группа:** ЦИБ-241

**Вариант:** №2

---

## 🎯 Цель работы.

Изучить принципы обнаружения отказов в распределенных системах с помощью симуляции трех протоколов (Gossip/Serf, Heartbeat, Ping) и проанализировать влияние **масштабирования системы** (количества узлов) на время конвергенции и загрузку сети.

**Параметры варианта №2:**
- Интервал рассылки (Gossip Interval): **0.2 с**
- Количество соседей (Fanout): **3**
- Потеря пакетов (Packet Loss): **0%**
- Отказ узлов (Node Failures): **5%**
- Исследуемые размеры сети: **10, 50, 100, 200, 500 узлов**

---

## 📚 Теоретическая часть.

### Что такое обнаружение отказов?

**Обнаружение отказов (Failure Detection)** — механизм в распределенных системах, позволяющий узлам определять, когда другие узлы перестали функционировать. Без этого механизма система не может:
- реагировать на сбои
- переназначать задачи
- поддерживать отказоустойчивость

### Три протокола обнаружения отказов

| Протокол | Принцип работы | Сложность трафика |
|----------|---------------|-------------------|
| **Heartbeat (Full-mesh)** | Каждый узел пингует **всех остальных** каждый такт | O(N²) — квадратичная |
| **Gossip (Serf)** | Каждый узел общается со **случайными соседями** (fanout=3) | O(N) — линейная |
| **Ping (Random Probe)** | Каждый узел пингует **одного случайного** соседа | O(N) — линейная |

### Понятие конвергенции.

**Конвергенция** — состояние, когда **все живые узлы** системы пришли к согласованному представлению о том, какие узлы отказали.

---

## Импорт всех необходимых библиотек.

```
# Ячейка 1: Импорт всех необходимых библиотек
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import random
import time
import warnings
warnings.filterwarnings('ignore')

# Настройка стиля графиков
plt.style.use('seaborn-v0_8-whitegrid')
plt.rcParams['figure.figsize'] = (12, 6)
plt.rcParams['font.size'] = 11

print("✅ Библиотеки загружены!")
```

## 📐 Часть 1. Расчет полосы пропускания.

### Формула расчета.

Теоретическая формула для оценки потребления сети протоколом **Gossip**:

$$
\text{Bandwidth} = \frac{1}{\text{Interval}} \times \text{Fanout} \times \text{ActiveNodes} \times \text{PacketSize} \times \text{Overhead} \times 8
$$

### Параметры формулы

| Параметр | Описание |
|----------|----------|
| **Interval** | интервал между раундами (секунды) |
| **Fanout** | количество соседей |
| **ActiveNodes** | Nodes × (1 − NodeFailures) |
| **PacketSize** | 1024 байт (типичный размер) |
| **Overhead** | 1.2 (20% накладные расходы) |


# График зависимости bandwidth от количества узлов.

``` python
# Ячейка 3: График зависимости bandwidth от количества узлов (Вариант 2)

# Параметры для варианта №2
gossip_interval = 0.2
fanout = 3
nodes_list = [10, 50, 100, 200, 500]
packet_loss = 0
node_failures = 0.05

# Расчет bandwidth для каждого размера сети
bandwidths = [calculate_bandwidth(gossip_interval, fanout, nodes, packet_loss/100, node_failures) for nodes in nodes_list]
bandwidths_mbps = [bw / 1_000_000 for bw in bandwidths]

# Таблица результатов
print("="*70)
print(f"{'Nodes':<15} | {'Bandwidth (бит/с)':<25} | {'Bandwidth (Мбит/с)':<15}")
print("="*70)
for nodes, bw, bw_mbps in zip(nodes_list, bandwidths, bandwidths_mbps):
    print(f"{nodes:<15} | {bw:>25.0f} | {bw_mbps:>15.2f}")
print("="*70)

# Вывод графиков
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# График 1: Столбчатая диаграмма
ax1.bar(range(len(nodes_list)), bandwidths_mbps, color='#3498db', edgecolor='black')
ax1.set_xticks(range(len(nodes_list)))
ax1.set_xticklabels([f'{n}' for n in nodes_list])
ax1.set_ylabel('Bandwidth (Мбит/с)')
ax1.set_xlabel('Количество узлов')
ax1.set_title('Зависимость полосы пропускания от количества узлов\n(Interval=0.2с, 5% отказов, 0% потерь)')
ax1.grid(axis='y', alpha=0.7)

# График 2: Линейный график
ax2.plot(nodes_list, bandwidths_mbps, 'o-', color='#e74c3c', linewidth=2, markersize=10)
ax2.set_xlabel('Количество узлов')
ax2.set_ylabel('Bandwidth (Мбит/с)')
ax2.set_title('Линейный рост полосы пропускания')
ax2.grid(True, alpha=0.7)

plt.suptitle('Вариант 2: Масштабируемость системы - полоса пропускания\n(Interval=0.2с, Fanout=3, 5% отказов, 0% потерь)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.show()

print("\nВывод:")
print("Полоса пропускания линейно растет с увеличением количества узлов в сети.")
print(f"При увеличении сети с 10 до 500 узлов полоса пропускания увеличивается с {bandwidths_mbps[0]:.2f} до {bandwidths_mbps[-1]:.2f} Мбит/с.")
```
<img width="1399" height="628" alt="image" src="https://github.com/user-attachments/assets/f55100de-e1b3-4401-87ef-1f8cc48531b2" />

## Вывод:
Полоса пропускания линейно растет с увеличением количества узлов в сети.
При увеличении сети с 10 до 500 узлов полоса пропускания увеличивается с 1.40 до 70.04 Мбит/с.




# 📈 Часть 3. Исследование влияния параметров.
3.1 Влияние Gossip Interval

``` sql
# Ячейка 2: Класс SerfSimulator и функция calculate_bandwidth

class SerfSimulator:
    def __init__(self, num_nodes, gossip_interval, fanout, packet_loss_percent, failure_percent):
        self.num_nodes = num_nodes
        self.gossip_interval = gossip_interval
        self.fanout = fanout
        self.packet_loss = packet_loss_percent / 100
        self.failure_prob = failure_percent / 100

    def run_simulation(self):
        nodes = []
        for i in range(self.num_nodes):
            is_alive = random.random() > self.failure_prob
            nodes.append({
                'id': i,
                'has_message': i == 0,
                'is_alive': is_alive,
                'received_time': 0 if i == 0 else None
            })

        if not nodes[0]['is_alive']:
            return 0, float('inf'), 0

        current_time = 0
        informed_count = 1 if nodes[0]['is_alive'] else 0

        alive_nodes = [n for n in nodes if n['is_alive']]
        target_informed = len(alive_nodes)

        while informed_count < target_informed and current_time < 50:
            current_time += self.gossip_interval

            informed_alive = [n for n in nodes if n['has_message'] and n['is_alive']]

            for sender in informed_alive:
                possible_targets = [n for n in nodes if n['is_alive'] and n['id'] != sender['id']]
                if not possible_targets:
                    continue

                n_targets = min(self.fanout, len(possible_targets))
                targets = random.sample(possible_targets, n_targets)

                for target in targets:
                    if random.random() < self.packet_loss:
                        continue

                    if not target['has_message']:
                        target['has_message'] = True
                        target['received_time'] = current_time
                        informed_count += 1

            alive_nodes = [n for n in nodes if n['is_alive']]
            target_informed = len(alive_nodes)

        convergence_time = current_time if informed_count >= target_informed else float('inf')
        return 0, convergence_time, informed_count


def calculate_bandwidth(gossip_interval, gossip_fanout, nodes, packet_loss, node_failures):
    PACKET_SIZE = 1024
    OVERHEAD = 1.2
    active_nodes = nodes * (1 - node_failures)
    messages_per_second = (1 / gossip_interval) * gossip_fanout * active_nodes
    effective_messages = messages_per_second * (1 - packet_loss)
    data_per_second = effective_messages * PACKET_SIZE * OVERHEAD
    bandwidth_bps = data_per_second * 8
    return bandwidth_bps


# Ячейка 3: Исследование для варианта 2

def study_interval_effect():
    """
    ВАРИАНТ №2: масштабируемость (10, 50, 100, 200, 500 узлов, 5% отказов, 0% потерь)
    """
    nodes_list = [10, 50, 100, 200, 500]
    gossip_interval = 0.2
    fanout = 3
    packet_loss = 0
    failures = 5

    convergence_times = []
    bandwidths_calculated = []

    for nodes in nodes_list:
        times = []
        for _ in range(10):
            sim = SerfSimulator(nodes, gossip_interval, fanout, packet_loss, failures)
            _, all_time, _ = sim.run_simulation()
            if all_time != float('inf') and all_time < 100:
                times.append(all_time)

        if times:
            times_sorted = sorted(times)
            if len(times_sorted) > 4:
                times_sorted = times_sorted[1:-1]
            convergence_times.append(np.mean(times_sorted))
        else:
            convergence_times.append(float('inf'))

        bw = calculate_bandwidth(gossip_interval, fanout, nodes, packet_loss/100, failures/100)
        bandwidths_calculated.append(bw / 1_000_000)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.plot(nodes_list, convergence_times, 'o-', color='#3498db', linewidth=2, markersize=10)
    ax1.set_xlabel('Количество узлов', fontsize=12)
    ax1.set_ylabel('Время конвергенции (сек)', fontsize=12)
    ax1.set_title('Влияние количества узлов на время конвергенции\n(Interval=0.2с, 5% отказов, 0% потерь)', fontsize=12)
    ax1.grid(True, alpha=0.7)

    ax2.plot(nodes_list, bandwidths_calculated, 's-', color='#e74c3c', linewidth=2, markersize=10)
    ax2.set_xlabel('Количество узлов', fontsize=12)
    ax2.set_ylabel('Полоса пропускания (Мбит/с)', fontsize=12)
    ax2.set_title('Влияние количества узлов на полосу пропускания', fontsize=12)
    ax2.grid(True, alpha=0.7)

    plt.suptitle('Вариант №2: Масштабируемость системы', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.show()

    print("\n📊 РЕЗУЛЬТАТЫ ВАРИАНТА №2:")
    print("="*60)
    print(f"{'Узлы':<12} | {'Конвергенция (с)':<18} | {'Bandwidth (Мбит/с)':<18}")
    print("-"*60)
    for i, nodes in enumerate(nodes_list):
        conv = convergence_times[i] if convergence_times[i] != float('inf') else 0
        print(f"{nodes:<12} | {conv:<18.2f} | {bandwidths_calculated[i]:<18.4f}")
    print("="*60)

    return nodes_list, convergence_times, bandwidths_calculated

nodes_list, conv_times, bw_calc = study_interval_effect()
```

<img width="1337" height="652" alt="image" src="https://github.com/user-attachments/assets/527e832e-4ddd-45d6-be66-409bcd437ab1" />


## 🔬 ЗАПУСК ИССЛЕДОВАНИЯ.

ИССЛЕДОВАНИЕ МАСШТАБИРУЕМОСТИ СИСТЕМЫ
Параметры: interval=0.2c, fanout=3, потери=0%, отказы=5%
``` python
# ============================================
# ИССЛЕДОВАНИЕ МАСШТАБИРУЕМОСТИ СИСТЕМЫ
# ВАРИАНТ №2: Разные размеры сети, interval=0.2с, 5% отказов, 0% потерь
# ============================================

%matplotlib inline
import numpy as np
import matplotlib.pyplot as plt
import random

def study_scalability_variant2():
    """
    Исследование масштабируемости для варианта №2
    """
    # Параметры для варианта №2
    nodes_list = [10, 50, 100, 200, 500]
    interval = 0.2
    fanout = 3
    packet_loss = 0
    failures = 5

    convergence_times = []
    message_counts = []

    print("="*60)
    print("ИССЛЕДОВАНИЕ МАСШТАБИРУЕМОСТИ СИСТЕМЫ")
    print(f"Параметры: interval={interval}c, fanout={fanout}, потери={packet_loss}%, отказы={failures}%")
    print("="*60)

    for nodes in nodes_list:
        print(f"Узлов {nodes}...", end=" ")

        convs = []
        msgs = []

        for _ in range(5):
            sim = SerfSimulator(nodes, interval, fanout, packet_loss, failures)
            _, conv, msg = sim.run_simulation(max_time=1000)

            if conv != float('inf'):
                convs.append(conv)
                msgs.append(msg)

        if convs:
            avg_conv = np.mean(convs)
            avg_msgs = np.mean(msgs)
            convergence_times.append(avg_conv)
            message_counts.append(avg_msgs)
            print(f"конвергенция = {avg_conv:.2f}с")
        else:
            convergence_times.append(float('inf'))
            message_counts.append(0)
            print("❌ нет данных")

    # ==========================================
    # ПОСТРОЕНИЕ ГРАФИКОВ
    # ==========================================

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # ГРАФИК 1: Время конвергенции vs Количество узлов
    ax1 = axes[0]

    valid_nodes = []
    valid_convs = []
    for i, nodes in enumerate(nodes_list):
        if convergence_times[i] != float('inf'):
            valid_nodes.append(nodes)
            valid_convs.append(convergence_times[i])

    if valid_nodes:
        ax1.plot(valid_nodes, valid_convs, 'o-', color='#e74c3c', linewidth=2, markersize=10)
        ax1.fill_between(valid_nodes, valid_convs, alpha=0.3, color='#e74c3c')

    ax1.set_xlabel('Количество узлов', fontsize=12)
    ax1.set_ylabel('Время конвергенции (сек)', fontsize=12)
    ax1.set_title(f'Влияние размера сети на время конвергенции\n(interval={interval}c, {failures}% отказов)', fontsize=11)
    ax1.grid(True, alpha=0.5)

    # ГРАФИК 2: Количество сообщений vs Количество узлов
    ax2 = axes[1]

    valid_msgs = []
    for i, nodes in enumerate(nodes_list):
        if message_counts[i] > 0:
            valid_msgs.append(message_counts[i])

    if valid_nodes and valid_msgs:
        ax2.plot(valid_nodes, valid_msgs, 's-', color='#3498db', linewidth=2, markersize=10)
        ax2.fill_between(valid_nodes, valid_msgs, alpha=0.3, color='#3498db')

    ax2.set_xlabel('Количество узлов', fontsize=12)
    ax2.set_ylabel('Количество сообщений', fontsize=12)
    ax2.set_title('Влияние размера сети на трафик', fontsize=11)
    ax2.grid(True, alpha=0.5)

    plt.suptitle(f'Вариант №2: Масштабируемость системы\n(interval={interval}c, fanout={fanout}, {failures}% отказов, {packet_loss}% потерь)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.show()

    # ==========================================
    # ВЫВОД ТАБЛИЦЫ
    # ==========================================
    print("\n📊 РЕЗУЛЬТАТЫ ИССЛЕДОВАНИЯ:")
    print("="*65)
    print(f"{'Узлов':<12} | {'Конвергенция (с)':<20} | {'Сообщений':<15}")
    print("-"*65)
    for i, nodes in enumerate(nodes_list):
        conv = convergence_times[i] if convergence_times[i] != float('inf') else 0
        msg = message_counts[i] if message_counts[i] > 0 else 0
        print(f"{nodes:<12} | {conv:<20.2f} | {msg:<15.0f}")
    print("="*65)

    # ==========================================
    # ВЫВОДЫ
    # ==========================================
    print("\n💡 ВЫВОДЫ ПО ИССЛЕДОВАНИЮ:")
    print("-"*50)
    print("1. При увеличении узлов с 10 до 500 время конвергенции растет")
    print("2. Количество сообщений растет линейно с размером сети")
    print("3. Система сохраняет работоспособность при 500 узлах")
    print("4. Gossip протокол хорошо масштабируется для сетей до 500 узлов")

    return nodes_list, convergence_times, message_counts

# ЗАПУСК
print("\n🔬 ЗАПУСК ИССЛЕДОВАНИЯ...")
nodes, convs, msgs = study_scalability_variant2()
print("\n✅ Исследование завершено!")
```

<img width="1372" height="733" alt="image" src="https://github.com/user-attachments/assets/d352fbb4-ec6a-4641-b20a-0859313a53c1" />

## ВЫВОДЫ ПО ИССЛЕДОВАНИЮ.

1. При увеличении узлов с 10 до 500 время конвергенции растет
2. Количество сообщений растет линейно с размером сети
3. Система сохраняет работоспособность при 500 узлах
4. Gossip протокол хорошо масштабируется для сетей до 500 узлов

## Сравнительный анализ протоколов.

``` python
# Ячейка 8: Запуск сравнительного анализа для разных размеров сети (Вариант 2)

def compare_protocols(num_nodes, node_failures=5, num_trials=10):
    """
    Сравнение трех протоколов обнаружения отказов
    """
    results = {'Serf (Gossip)': [], 'Heartbeat': [], 'Ping': []}

    print(f"Запуск сравнения для {num_nodes} узлов, {node_failures}% отказов...")
    print(f"Количество запусков: {num_trials}")
    print("-"*50)

    for trial in range(num_trials):
        print(f"  Запуск {trial+1}/{num_trials}...", end=" ")

        # Serf (Gossip) - параметры для варианта 2
        serf = SerfSimulator(num_nodes, 0.2, 3, 0, node_failures)
        first, all_time, bw = serf.run_simulation()
        results['Serf (Gossip)'].append({'first': first, 'all': all_time, 'bw': bw})

        # Heartbeat
        hb = HeartbeatSimulator(num_nodes, 0.2, node_failures)
        first, all_time, bw = hb.run_simulation()
        results['Heartbeat'].append({'first': first, 'all': all_time, 'bw': bw})

        # Ping
        ping = PingSimulator(num_nodes, 0.2, node_failures)
        first, all_time, bw = ping.run_simulation()
        results['Ping'].append({'first': first, 'all': all_time, 'bw': bw})

        print("✓")

    return results

# Запуск сравнения для разных размеров сети (Вариант 2)
print("\n" + "="*60)
print("ЭТАП 3: Сравнительный анализ протоколов (Вариант №2)")
print("Параметры: Interval=0.2с, Fanout=3, 0% потерь, 5% отказов")
print("="*60)

nodes_list = [10, 50, 100, 200, 500]
all_results = {}

for nodes in nodes_list:
    print(f"\n🔬 ИССЛЕДОВАНИЕ ДЛЯ {nodes} УЗЛОВ:")
    print("-"*50)
    results = compare_protocols(num_nodes=nodes, node_failures=5, num_trials=10)
    all_results[nodes] = results
    print()

print("\n✅ Симуляция завершена!")

# Вывод сводной таблицы результатов
print("\n" + "="*70)
print("СВОДНАЯ ТАБЛИЦА РЕЗУЛЬТАТОВ (Вариант №2)")
print("="*70)

for nodes in nodes_list:
    print(f"\n📊 {nodes} УЗЛОВ:")
    print("-"*50)
    for protocol in ['Serf (Gossip)', 'Heartbeat', 'Ping']:
        times = [r['all'] for r in all_results[nodes][protocol]]
        bandwidths = [r['bw'] for r in all_results[nodes][protocol]]
        if times:
            avg_time = np.mean(times)
            avg_bw = np.mean(bandwidths)
            print(f"  {protocol:<18}: время = {avg_time:.2f}с, сообщений = {avg_bw:.0f}")
        else:
            print(f"  {protocol:<18}: нет данных")
```

<img width="517" height="581" alt="image" src="https://github.com/user-attachments/assets/c21e1ddc-9e6b-43ea-a38f-f8b4179219db" />

## Построение сравнительных графиков для разных размеров сети.
``` python
# Ячейка 9: Построение сравнительных графиков для разных размеров сети (Вариант 2)

nodes_list = [10, 50, 100, 200, 500]
protocols = ['Serf (Gossip)', 'Heartbeat', 'Ping']
colors = ['#3498db', '#e74c3c', '#2ecc71']

# Создание графиков - 5 строк по 3 графика
fig, axes = plt.subplots(5, 3, figsize=(18, 25))
axes = axes.flatten()

plot_idx = 0
for nodes in nodes_list:
    results = all_results[nodes]

    first_times = [[r['first'] for r in results[p]] for p in protocols]
    all_times = [[r['all'] for r in results[p]] for p in protocols]
    bandwidths = [[r['bw'] for r in results[p]] for p in protocols]

    # ВЫВОД СТАТИСТИКИ
    print(f"\n🔍 ПРОВЕРКА ДАННЫХ ДЛЯ {nodes} УЗЛОВ:")
    print("="*60)
    for i, p in enumerate(protocols):
        avg_first = np.mean(first_times[i])
        avg_all = np.mean(all_times[i])
        avg_bw = np.mean(bandwidths[i])
        print(f"\n📊 {p}:")
        print(f"   Первое обнаружение: {avg_first:.2f} сек")
        print(f"   Полная конвергенция: {avg_all:.2f} сек")
        print(f"   Сообщений: {avg_bw:.0f}")
    print("="*60)

    # ГРАФИК 1: Время первого обнаружения
    ax1 = axes[plot_idx]
    bp1 = ax1.boxplot(first_times, labels=protocols, patch_artist=True)
    for patch, color in zip(bp1['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax1.set_ylabel('Время (секунды)', fontsize=10)
    ax1.set_title(f'{nodes} узлов - Первое обнаружение', fontsize=10)
    ax1.grid(axis='y', alpha=0.5)
    ax1.set_ylim(bottom=0)
    plot_idx += 1

    # ГРАФИК 2: Время полной конвергенции
    ax2 = axes[plot_idx]
    bp2 = ax2.boxplot(all_times, labels=protocols, patch_artist=True)
    for patch, color in zip(bp2['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax2.set_ylabel('Время (секунды)', fontsize=10)
    ax2.set_title(f'{nodes} узлов - Полная конвергенция', fontsize=10)
    ax2.grid(axis='y', alpha=0.5)
    ax2.set_ylim(bottom=0)
    plot_idx += 1

    # ГРАФИК 3: Количество сообщений (трафик)
    ax3 = axes[plot_idx]
    bp3 = ax3.boxplot(bandwidths, labels=protocols, patch_artist=True)
    for patch, color in zip(bp3['boxes'], colors):
        patch.set_facecolor(color)
        patch.set_alpha(0.7)
    ax3.set_ylabel('Количество сообщений', fontsize=10)
    ax3.set_title(f'{nodes} узлов - Трафик', fontsize=10)
    ax3.grid(axis='y', alpha=0.5)
    ax3.set_yscale('log')
    plot_idx += 1

plt.suptitle('Вариант №2: Сравнение протоколов обнаружения отказов\n(Interval=0.2с, Fanout=3, 5% отказов, 0% потерь)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.show()

# ==========================================
# СВОДНАЯ ТАБЛИЦА ПО ВСЕМ РАЗМЕРАМ
# ==========================================
print("\n" + "="*80)
print("📊 СВОДНАЯ ТАБЛИЦА РЕЗУЛЬТАТОВ (Вариант №2)")
print("="*80)
print(f"{'Узлов':<8} | {'Протокол':<18} | {'Первое (с)':<12} | {'Конвергенция (с)':<18} | {'Сообщений':<12}")
print("-"*80)

for nodes in nodes_list:
    results = all_results[nodes]
    for protocol in protocols:
        times_first = [r['first'] for r in results[protocol]]
        times_all = [r['all'] for r in results[protocol]]
        bw = [r['bw'] for r in results[protocol]]

        avg_first = np.mean(times_first)
        avg_all = np.mean(times_all)
        avg_bw = np.mean(bw)

        print(f"{nodes:<8} | {protocol:<18} | {avg_first:<12.2f} | {avg_all:<18.2f} | {avg_bw:<12.0f}")
    print("-"*80)

# ==========================================
# ВЫВОДЫ
# ==========================================
print("\n" + "="*80)
print("💡 ВЫВОДЫ ПО СРАВНЕНИЮ ПРОТОКОЛОВ (Вариант №2):")
print("="*80)

for nodes in nodes_list:
    results = all_results[nodes]

    avg_first_list = [np.mean([r['first'] for r in results[p]]) for p in protocols]
    avg_all_list = [np.mean([r['all'] for r in results[p]]) for p in protocols]
    avg_bw_list = [np.mean([r['bw'] for r in results[p]]) for p in protocols]

    best_first = protocols[np.argmin(avg_first_list)]
    best_conv = protocols[np.argmin(avg_all_list)]
    best_traffic = protocols[np.argmin(avg_bw_list)]

    print(f"\n📌 ДЛЯ {nodes} УЗЛОВ:")
    print(f"   🚀 Самый быстрый по первому обнаружению: {best_first}")
    print(f"   ⚡ Самый быстрый по полной конвергенции: {best_conv}")
    print(f"   💰 Самый экономичный по трафику: {best_traffic}")

print("\n" + "="*80)
print("📌 ИТОГОВАЯ РЕКОМЕНДАЦИЯ ДЛЯ ВАРИАНТА №2:")
print("   Heartbeat — самый быстрый, но создает огромный трафик (O(N²))")
print("   Gossip — лучший баланс скорости и трафика (O(N))")
print("   Ping — экономичный, но очень медленный")
print("="*80)

print("\n✅ Для масштабируемых распределенных систем рекомендуется GOSSIP")
```
Пример для 10 узлов.

<img width="1774" height="477" alt="image" src="https://github.com/user-attachments/assets/083fcb82-3fb4-48c2-a9a2-b5cbe5b17c16" />

<img width="634" height="629" alt="image" src="https://github.com/user-attachments/assets/4ca69730-8ddf-47fe-af8b-e85ecf72709a" />

## График trade-off (скорость vs трафик).

``` python
# Ячейка 11: График trade-off (скорость vs трафик) ДЛЯ ВАРИАНТА №2

# Данные из ВАРИАНТА №2
nodes_list = [10, 50, 100, 200, 500]
# conv_times и msgs должны быть получены из study_scalability_variant2()

fig, ax = plt.subplots(figsize=(10, 6))

# Построение точек для каждого размера сети (ваш вариант №2)
for i, nodes in enumerate(nodes_list):
    conv = conv_times[i] if conv_times[i] != float('inf') else 0
    msg = msgs[i]
    ax.scatter(conv, msg, s=200, c='#e74c3c', edgecolors='black', linewidths=2)
    ax.annotate(f'Узлов={nodes}', (conv, msg),
                xytext=(10, 10), textcoords='offset points', fontsize=10)

ax.set_xlabel('Время конвергенции (сек) - меньше = лучше', fontsize=12)
ax.set_ylabel('Количество сообщений - меньше = лучше', fontsize=12)
ax.set_title('Trade-off анализ для ВАРИАНТА №2\n(Interval=0.2с, Fanout=3, 5% отказов, 0% потерь)', fontsize=14)
ax.grid(True, alpha=0.3)

# Добавление стрелки "лучше"
ax.annotate('Лучше ↑', xy=(0.5, 0.1), xytext=(2, 0.5),
            arrowprops=dict(arrowstyle='->', color='green'), fontsize=10, color='green')

plt.tight_layout()
plt.show()

print("\n💡 Идеальная точка: левый нижний угол (быстро и мало сообщений)")
print(f"\n📊 АНАЛИЗ ДЛЯ ВАРИАНТА №2:")

for i, nodes in enumerate(nodes_list):
    conv = conv_times[i] if conv_times[i] != float('inf') else 0
    msg = msgs[i]
    if nodes == 10:
        print(f"   - {nodes} узлов: быстро ({conv:.2f}с), но мало сообщений ({msg:.0f})")
    elif nodes == 50:
        print(f"   - {nodes} узлов: быстро ({conv:.2f}с), сообщений ({msg:.0f})")
    elif nodes == 100:
        print(f"   - {nodes} узлов: оптимальный баланс ({conv:.2f}с, {msg:.0f} сообщений)")
    elif nodes == 200:
        print(f"   - {nodes} узлов: медленнее ({conv:.2f}с), сообщений ({msg:.0f})")
    elif nodes == 500:
        print(f"   - {nodes} узлов: медленно ({conv:.2f}с), много сообщений ({msg:.0f})")

print("\n✅ Рекомендуемый размер сети: до 200 узлов для хорошей производительности")
```
<img width="691" height="740" alt="image" src="https://github.com/user-attachments/assets/2b1e31e1-05d6-4e8b-ba7f-8864f1cba00d" />

## ВЫВОДЫ ПО ВАРИАНТУ №2 (Масштабируемость системы).


📌 1. ЗАВИСИМОСТЬ ВРЕМЕНИ КОНВЕРГЕНЦИИ ОТ РАЗМЕРА СЕТИ:
   - При 10 узлах → конвергенция за 0.36 сек (БЫСТРО)
   - При 500 узлах → конвергенция за 1.26 сек (МЕДЛЕННО)
   - Зависимость: чем БОЛЬШЕ узлов, тем МЕДЛЕННЕЕ конвергенция

📌 2. ЗАВИСИМОСТЬ КОЛИЧЕСТВА СООБЩЕНИЙ ОТ РАЗМЕРА СЕТИ:
   - При 10 узлах → 30 сообщений (МАЛО)
   - При 500 узлах → 6555 сообщений (МНОГО)
   - Зависимость: примерно линейная (сообщения ∝ N)

📌 3. ОПТИМАЛЬНЫЙ БАЛАНС (Trade-off):
   - Рекомендуемый размер сети: до 100-200 узлов
   - Время конвергенции при 100 узлах: ~0.88 сек
   - Сообщений при 100 узлах: ~912
   - Это золотая середина между скоростью и нагрузкой на сеть

📌 4. ВЫВОД ДЛЯ МАСШТАБИРУЕМОСТИ (Interval=0.2с, Fanout=3, 5% отказов, 0% потерь):
   - Для критичных по времени систем: до 50 узлов
   - Для экономии трафика: 10-50 узлов
   - Компромиссный вариант: 100-200 узлов (РЕКОМЕНДУЕТСЯ)


