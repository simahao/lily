# 浮点数的一些知识

## 1. 问题

1. **问题1**

   对于java代码，下面结果输出是什么？

   ```java
       float fSum = 0.0f;
       for (int i = 0; i < 1000000; i++) {
           fSum += 0.1f;
       }
       System.out.printf("sum:%.3f\n", fSum);
   	
   
   
   
       result
       -----------------
       sum:100958.344
   ```

2. **问题2**

   同样遵守IEEE754浮点数标准，为什么同样的变量，java和C++输出结果不同？

   ```c++
       //C++
       double var = 3.425;
       printf("var=%.16f\n", var);
   
       result
       ____________________
       var=3.4249999999999998
   
   
       //Java
       double var = 3.425;
       System.out.printf("var=%.16f\n", var);
   
       result
       ____________________
       var=3.4250000000000000
           
       //Java
       System.out.println(new BigDecimal(var).toPlainString())
       //3.42499999999999982236431605997495353221893310546875
   ```

   ![3.425](./3.425.png)

3. **问题3**

   数据库中（oracle）存储的数值为**932.525**，在C++的客户端中保留两位小数显示为**932.52**，但是在基于Javascript的前端保留两位小数后显示**932.53**，谁显示的是对的？

4. **问题4**

   不同的语言，如果涉及到互相调用，浮点型参数传递时，应该如何处理？

5. **问题5**

   Java语言中，为什么BigDecimal就可以表达任意的精度

## 2. IEEE 754简介

### 2. 1. 科学计数法

十进制的科学技术法通常用一个数字乘以$$a*10^n$$来表示

- $$57.34=5.734*10^2$$

- $$0.03424=3.424*10^{-2}$$

### 2.2. **有效位数 vs 精度**

两个相关但是不完全相同的概念

1. **有效位数（Significant Digits）**

   有效位数指的是数值中从最高有效位（不为零的第一位）到最后一位的总位数，用于衡量一个数值的**表示范围内的信息量**

   * 数值 `1.234` 有 4 位有效数字

   * 数值 `1.234 × 10³` 有 4 位有效数字

   * 数值 `0.00123` 有 3 位有效数字（前导零不算有效位数）

2. **精度（Precision）**

   **精度**在 IEEE 754 中是一个更广泛的概念，指的是浮点数表示值的**分辨能力**，即能够区分两个相邻数值的能力，同时也表达数字的范围。精度可以分为**绝对精度**和**相对精度**。

 **特点**:

- **绝对精度**:
  表示特定范围内的最小增量（ULP，单位最小增量）。
  **公式**：绝对精度为$$ULP=2^{e−52}$$（双精度）
- **相对精度**:
  表示分辨能力与数值大小的比值，通常是相对固定的，比如 IEEE 754 双精度浮点数的相对精度是 $$2^{−52}$$
- **动态变化**:
  绝对精度随数值大小和指数变化而变化，但相对精度恒定。

 **示例**:

- 对于数值 1.0 ，其最小增量 $$ULP=2^{-52}$$，绝对精度约为 $$2.22×10^{−16}$$
- 对于数值 10.0，其最小增量 $$ULP=2^{−49}$$，但相对精度仍为 $$2^{−52}$$

**有效位数和精度的区别**

| **属性**       | **有效位数（Significant Digits）**               | **精度（Precision）**                                        |
| -------------- | ------------------------------------------------ | ------------------------------------------------------------ |
| **定义**       | 浮点数表示中有效的、有意义的位数                 | 浮点数在当前范围内的分辨能力，包括绝对精度和相对精度。       |
| **单位**       | 表示数字总共有多少位有效信息（十进制或二进制位） | 表示数值范围内的最小增量（绝对精度）或分辨能力（相对精度）   |
| **固定性**     | 有效位数是固定的（双精度为 53 位二进制有效位）   | 精度动态变化，绝对精度随数值范围变化，而相对精度是固定的     |
| **表现形式**   | 描述浮点数能可靠表示的位数（在十进制或二进制中） | 描述浮点数在特定数值范围的分辨能力（ULP 和相对分辨能力）     |
| **随范围变化** | 不变（固定有效位宽）                             | 绝对精度随指数和数值范围变化，相对精度保持恒定               |
| **设计目的**   | 提供一个固定的位数，用于表示数值中的全部有效信息 | 提供适应动态范围的分辨能力，用于表示浮点数在不同数值范围的精确性 |

### 2.3. 浮点型存储结构

在计算机中，浮点数也利用科学计数法来表达，但是计算机使用二进制，所以就采用二进制的科学计数法来表达。浮点数（双精度64位）存储结构：

![IEEE754_Double_Point](./IEEE_754_Double_Floating_Point_Format.png)

浮点数是由三部分组成，分别是符号位（sign）、指数位（exponent）、尾数（mantissa/fraction）

- **Sign bit: 1 bit**

  符号位决定了数字是正数还是负数，**二进制0代表正数，1代表负数**

- **Exponent: 11 bits**

  指数是由11位组成，代表$$[0,2047]$$（$$2047=2^{11}-1$$）。参考十进制小数的科学计数法（比如说$$3.2×0^{-2}$$），二进制为了表达小数，指数也需要支持负数。通过二进制偏移方法，可以做到这一点，我们用一个例子来说明这一点。如果有一个类别的浮点数用4位来表达指数（假想的例子），那么指数的范围为$$e\in[0,2^4-1]$$，偏移量为$$2^{n-1}-1=2^{3}-1=7$$。存储指数为二进制存储结构中存储的数据所代表的十进制值，为了能够表达负指数，每一个指数都减去7，这样原本$$[0,15]$$的表达范围变成了$$[-7,8]$$，针对双精度浮点数，偏移量=$$2^{11-1}-1=1023$$。因此$e\in[2^{0-1023}, 2^{2047-1023}]=e\in[2^{-1023},2^{1024}]$，但是$-1023,1024$是两个特殊的值，分别代表非规格化数据（非规格化数用于表示非常接近于零的数）、负无穷与正无穷（正负靠符号位决定），所以最终的指数范围为$e\in[2^{-1022}, 2^{1023}]$。这个二进制的指数范围对应到十进制为$e\in[10^{-308}, 10^{308}]$。扩展一下，为什么是10的308次方呢？计算方式如下：$10^x\approx2^{1023}=>x\approx 1023 \times log_{10}^2=>x\approx 308$
  
  
  
  **偏移法**


  | 存储指数 | 存储指数二进制 | 实际指数 | 实际指数二进制（Two's complement） |
  | :------: | :------------: | :------: | :--------------------------------: |
  |    15    |      1111      |    8     |                1000                |
  |    14    |      1110      |    7     |                0111                |
  |    13    |      1101      |    6     |                0110                |
  |    12    |      1100      |    5     |                0101                |
  |    11    |      1011      |    4     |                0100                |
  |    10    |      1010      |    3     |                0011                |
  |    9     |      1001      |    2     |                0010                |
  |    8     |      1000      |    1     |                0001                |
  |    7     |      0111      |    0     |                0000                |
  |    6     |      0110      |    −1    |                1111                |
  |    5     |      0101      |    −2    |                1110                |
  |    4     |      0100      |    −3    |                1101                |
  |    3     |      0011      |    −4    |                1100                |
  |    2     |      0010      |    −5    |                1011                |
  |    1     |      0001      |    −6    |                1010                |
  |    0     |      0000      |    −7    |                1001                |

​    


- **Mantissa**: 53 bits (52 explicitly stored)

  留给有效精度的位数实际是52位，但是科学计数法一定是<font color='RED'>$1.b_1b_2...b_n*2^e$</font>，二进制非1即0，因此第一位一定是1，为了扩大精度，第一位的1作为固定值，因此位数从52变成53（这一位是隐藏值，不需要占用存储位）， double的精度表达范围为15到17位，那么为什么是15到17位有效数字？计算方式如下：$10^x\approx 2^{53}=>x\approx 53\times log_{10}^2=>x\approx16$


因此，二进制浮点数表达方式可以有两种方式，分别是二进制方式和十进制方式

- 二进制（Binary）

  $(-1)^{sign}(1.b_{51}b_{50}b_{49}...b_0)_2\times2^{e-1023}$
- 十进制（Decimal）

  $(-1)^{sign}\left(1+\sum_{i=1}^{52}b_{52-i}\times2^{-i}\right)\times2^{e-1023}$

编码举例：

$0\ 01111111111\ 0000000000000000000000000000000000000000000000000000_2=2^{1023-1023}\times (1+0)=2^0\times 1 = 1$

$0\ 01111111111\ 0000000000000000000000000000000000000000000000000001_2=2^{1023-1023}\times (1+2^{-52}) \approx 1.0000000000000002$

$0\ 01111111111\ 0000000000000000000000000000000000000000000000000010_2=2^{1023-1023} \times (1 + 2^{-51}) \approx 1.0000000000000004$

$1\ 10000000000\ 0000000000000000000000000000000000000000000000000000_2=-2^{1024-1023} \times (1 + 0) = -2$

$0\ 10000000000\ 1000000000000000000000000000000000000000000000000000_2=2^{1024-1023} \times (1 + 1 \times 2^{-1})=2\times1.5=3$

也可以利用位移法：$2^{1024-1023} \times 1.1_2=2^1 \times 1.1_2 = 11_2 =3$

$0\ 10000000011\ 0111000000000000000000000000000000000000000000000000_2=2^{1027-1023} \times 1.0111_2 = 2^4 \times 1.0111 = 10111_2=2^4+2^2+2^1+2^0=23$

$0\ 01111111000\ 1000000000000000000000000000000000000000000000000000_2=2^{1016-1023} \times 1.1_2 = 2^{-7} \times 1.1_2 = 0.00000011_2=1 \times 2^{-7} + 1 \times 2^{-8} = \frac{3}{2^8} = 0.01171875$

**Mininum positve number:**

$0\ 00000000001\ 0000000000000000000000000000000000000000000000000000_2=2^{1-1023} \times 1 \approx 2.225 \times 10^{-308}$

**Maximum positive number:**

$0\ 11111111110\ 1111111111111111111111111111111111111111111111111111_2=2^{2046-1023} \times (1 + (1 - 2^{-52})) \approx 1.798 \times 10^{308}$

$\sum_{i=1}^n2^i=2 \times \frac{1-2^n}{1 -2}$

$2^{-1} + 2^{-2} + ... + 2^{-52} = 2^{-1} \times \left(\frac{1-(1/2)^{52}}{1-2^{-1}}\right) =1-2^{-52}$

**+$\infty$**

$0\ 11111111111\ 0000000000000000000000000000000000000000000000000000_2=7FF0 0000 0000 0000_{16}=+\infty$

**-$\infty$**

$1\ 11111111111\ 0000000000000000000000000000000000000000000000000000_2=FFF0 0000 0000 0000_{16}=-\infty$

$0\ 11111111111\ 1111111111111111111111111111111111111111111111111111_2=7FFF FFFF FFFF FFFF_{16}=NaN$



## double vs Double (float vs Float)

Double是double的封装，其中提供了很多属性和方法，有如下类别：

- 属性类
  - 正无穷
  - 负无穷
  - NaN
  - ...
- bit<=>double
- 判断类
  - isNaN
  - isFinite
  - isInfinite
- compare
- parse
- valueOf
- equals
- toString

其中equals是判定两个double的bit完全一致才返回true，而我们在程序判定两个浮点数是否相同，往往要根据小数点保留的位数进行截断再判定，比如：

```JAVA
double a = 1.3456;
double b = 1.3458;
if (abs(a - b) < 0.001) {
    return true;
}
return false;
```

## BigDecimal

Java在java.math包中提供的API类BigDecimal，用来对超过16位有效位的数进行精确的运算。双精度浮点型变量double可以处理16位有效数，但在实际应用中，可能需要对更大或者更小的数进行运算和处理。一般情况下，对于那些不需要准确计算精度的数字，我们可以直接使用Double处理，但是Double.valueOf(String) 和Float.valueOf(String)会丢失精度。所以开发中，如果我们需要精确计算的结果，则必须使用BigDecimal类来操作。BigDecimal所创建的是对象，故我们不能使用传统的+、-、*、/等算术运算符直接对其对象进行数学运算，而必须调用其相对应的方法。在需要精确的小数计算时再使用BigDecimal，BigDecimal的性能比double和float差，在处理庞大，复杂的运算时尤为明显。故一般精度的计算没必要使用BigDecimal。

```java
BigDecimal a = new BigDecimal(0.1);
System.out.println("a values is:" + a);
System.out.println("=====================");
BigDecimal b = new BigDecimal("0.1");
System.out.println("b values is:" + b);

a values is:0.1000000000000000055511151231257827021181583404541015625
=====================
b values is:0.1
```



## 其他信息

### Java Double类中的常量

```java
public final class Double extends Number implements Comparable<Double> {
    /**
     * A constant holding the positive infinity of type
     * {@code double}. It is equal to the value returned by
     * {@code Double.longBitsToDouble(0x7ff0000000000000L)}.
     */
    public static final double POSITIVE_INFINITY = 1.0 / 0.0;

    /**
     * A constant holding the negative infinity of type
     * {@code double}. It is equal to the value returned by
     * {@code Double.longBitsToDouble(0xfff0000000000000L)}.
     */
    public static final double NEGATIVE_INFINITY = -1.0 / 0.0;

    /**
     * A constant holding a Not-a-Number (NaN) value of type
     * {@code double}. It is equivalent to the value returned by
     * {@code Double.longBitsToDouble(0x7ff8000000000000L)}.
     */
    public static final double NaN = 0.0d / 0.0;

    /**
     * A constant holding the largest positive finite value of type
     * {@code double},
     * (2-2<sup>-52</sup>)&middot;2<sup>1023</sup>.  It is equal to
     * the hexadecimal floating-point literal
     * {@code 0x1.fffffffffffffP+1023} and also equal to
     * {@code Double.longBitsToDouble(0x7fefffffffffffffL)}.
     */
    public static final double MAX_VALUE = 0x1.fffffffffffffP+1023; // 1.7976931348623157e+308

    /**
     * A constant holding the smallest positive normal value of type
     * {@code double}, 2<sup>-1022</sup>.  It is equal to the
     * hexadecimal floating-point literal {@code 0x1.0p-1022} and also
     * equal to {@code Double.longBitsToDouble(0x0010000000000000L)}.
     *
     * @since 1.6
     */
    public static final double MIN_NORMAL = 0x1.0p-1022; // 2.2250738585072014E-308

    /**
     * A constant holding the smallest positive nonzero value of type
     * {@code double}, 2<sup>-1074</sup>. It is equal to the
     * hexadecimal floating-point literal
     * {@code 0x0.0000000000001P-1022} and also equal to
     * {@code Double.longBitsToDouble(0x1L)}.
     */
    public static final double MIN_VALUE = 0x0.0000000000001P-1022; // 4.9e-324

    /**
     * Maximum exponent a finite {@code double} variable may have.
     * It is equal to the value returned by
     * {@code Math.getExponent(Double.MAX_VALUE)}.
     *
     * @since 1.6
     */
    public static final int MAX_EXPONENT = 1023;

    /**
     * Minimum exponent a normalized {@code double} variable may
     * have.  It is equal to the value returned by
     * {@code Math.getExponent(Double.MIN_NORMAL)}.
     *
     * @since 1.6
     */
    public static final int MIN_EXPONENT = -1022;

    /**
     * The number of bits used to represent a {@code double} value.
     *
     * @since 1.5
     */
    public static final int SIZE = 64;
    
    ....
}
```



## BigDecimal为什么可以任意精度表示



### Oracle中的浮点型问题



## 其他语言如何处理这个问题



## 建议

- web展示类：BigDeciaml

- 计算类
  - 大量计算但没有累计计算：double
  - 累计计算：转成Long，结果再转化为小数
