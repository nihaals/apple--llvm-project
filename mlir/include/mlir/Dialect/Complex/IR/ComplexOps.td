//===- ComplexOps.td - Complex op definitions ----------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef COMPLEX_OPS
#define COMPLEX_OPS

include "mlir/Dialect/Complex/IR/ComplexBase.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

class Complex_Op<string mnemonic, list<OpTrait> traits = []>
    : Op<Complex_Dialect, mnemonic, traits>;

// Base class for standard arithmetic operations on complex numbers with a
// floating-point element type. These operations take two operands and return
// one result, all of which must be complex numbers of the same type.
class ComplexArithmeticOp<string mnemonic, list<OpTrait> traits = []> :
    Complex_Op<mnemonic, traits # [NoSideEffect, SameOperandsAndResultType,
    Elementwise]> {
  let arguments = (ins Complex<AnyFloat>:$lhs, Complex<AnyFloat>:$rhs);
  let results = (outs Complex<AnyFloat>:$result);
  let assemblyFormat = "$lhs `,` $rhs  attr-dict `:` type($result)";
  let verifier = ?;
}

// Base class for standard unary operations on complex numbers with a
// floating-point element type. These operations take one operand and return
// one result; the operand must be a complex number.
class ComplexUnaryOp<string mnemonic, list<OpTrait> traits = []> :
    Complex_Op<mnemonic, traits # [NoSideEffect, Elementwise]> {
  let arguments = (ins Complex<AnyFloat>:$complex);
  let assemblyFormat = "$complex attr-dict `:` type($complex)";
  let verifier = ?;
}

//===----------------------------------------------------------------------===//
// AbsOp
//===----------------------------------------------------------------------===//

def AbsOp : ComplexUnaryOp<"abs",
    [TypesMatchWith<"complex element type matches result type",
                    "complex", "result",
                    "$_self.cast<ComplexType>().getElementType()">]> {
  let summary = "computes absolute value of a complex number";
  let description = [{
    The `abs` op takes a single complex number and computes its absolute value.

    Example:

    ```mlir
    %a = complex.abs %b : complex<f32>
    ```
  }];
  let results = (outs AnyFloat:$result);
}

//===----------------------------------------------------------------------===//
// AddOp
//===----------------------------------------------------------------------===//

def AddOp : ComplexArithmeticOp<"add"> {
  let summary = "complex addition";
  let description = [{
    The `add` operation takes two complex numbers and returns their sum.

    Example:

    ```mlir
    %a = complex.add %b, %c : complex<f32>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// CreateOp
//===----------------------------------------------------------------------===//

def CreateOp : Complex_Op<"create",
    [NoSideEffect,
     AllTypesMatch<["real", "imaginary"]>,
     TypesMatchWith<"complex element type matches real operand type",
                    "complex", "real",
                    "$_self.cast<ComplexType>().getElementType()">,
     TypesMatchWith<"complex element type matches imaginary operand type",
                    "complex", "imaginary",
                    "$_self.cast<ComplexType>().getElementType()">]> {

  let summary = "complex number creation operation";
  let description = [{
    The `complex.create` operation creates a complex number from two
    floating-point operands, the real and the imaginary part.

    Example:

    ```mlir
    %a = complex.create %b, %c : complex<f32>
    ```
  }];

  let arguments = (ins AnyFloat:$real, AnyFloat:$imaginary);
  let results = (outs Complex<AnyFloat>:$complex);

  let assemblyFormat = "$real `,` $imaginary attr-dict `:` type($complex)";
  let hasFolder = 1;
}

//===----------------------------------------------------------------------===//
// DivOp
//===----------------------------------------------------------------------===//

def DivOp : ComplexArithmeticOp<"div"> {
  let summary = "complex division";
  let description = [{
    The `div` operation takes two complex numbers and returns result of their
    division:

    ```mlir
    %a = complex.div %b, %c : complex<f32>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// EqualOp
//===----------------------------------------------------------------------===//

def EqualOp : Complex_Op<"eq",
    [NoSideEffect, AllTypesMatch<["lhs", "rhs"]>, Elementwise]> {
  let summary = "computes whether two complex values are equal";
  let description = [{
    The `eq` op takes two complex numbers and returns whether they are equal.

    Example:

    ```mlir
    %a = complex.eq %b, %c : complex<f32>
    ```
  }];

  let arguments = (ins Complex<AnyFloat>:$lhs, Complex<AnyFloat>:$rhs);
  let results = (outs I1:$result);
  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs), [{
      build($_builder, $_state, $_builder.getI1Type(), lhs, rhs);
    }]>];

  let assemblyFormat = "$lhs `,` $rhs  attr-dict `:` type($lhs)";
}

//===----------------------------------------------------------------------===//
// ExpOp
//===----------------------------------------------------------------------===//

def ExpOp : ComplexUnaryOp<"exp", [SameOperandsAndResultType]> {
  let summary = "computes exponential of a complex number";
  let description = [{
    The `exp` op takes a single complex number and computes the exponential of
    it, i.e. `exp(x)` or `e^(x)`, where `x` is the input value.
    `e` denotes Euler's number and is approximately equal to 2.718281.

    Example:

    ```mlir
    %a = complex.exp %b : complex<f32>
    ```
  }];

  let results = (outs Complex<AnyFloat>:$result);
}

//===----------------------------------------------------------------------===//
// ImOp
//===----------------------------------------------------------------------===//

def ImOp : ComplexUnaryOp<"im",
    [TypesMatchWith<"complex element type matches result type",
                    "complex", "imaginary",
                    "$_self.cast<ComplexType>().getElementType()">]> {
  let summary = "extracts the imaginary part of a complex number";
  let description = [{
    The `im` op takes a single complex number and extracts the imaginary part.

    Example:

    ```mlir
    %a = complex.im %b : complex<f32>
    ```
  }];

  let results = (outs AnyFloat:$imaginary);
  let hasFolder = 1;
}

//===----------------------------------------------------------------------===//
// LogOp
//===----------------------------------------------------------------------===//

def LogOp : ComplexUnaryOp<"log", [SameOperandsAndResultType]> {
  let summary = "computes natural logarithm of a complex number";
  let description = [{
    The `log` op takes a single complex number and computes the natural
    logarithm of it, i.e. `log(x)` or `log_e(x)`, where `x` is the input value.
    `e` denotes Euler's number and is approximately equal to 2.718281.

    Example:

    ```mlir
    %a = complex.log %b : complex<f32>
    ```
  }];

  let results = (outs Complex<AnyFloat>:$result);
}

//===----------------------------------------------------------------------===//
// MulOp
//===----------------------------------------------------------------------===//

def MulOp : ComplexArithmeticOp<"mul"> {
  let summary = "complex multiplication";
  let description = [{
    The `mul` operation takes two complex numbers and returns their product:

    ```mlir
    %a = complex.mul %b, %c : complex<f32>
    ```
  }];
}

//===----------------------------------------------------------------------===//
// NegOp
//===----------------------------------------------------------------------===//

def NegOp : ComplexUnaryOp<"neg", [SameOperandsAndResultType]> {
  let summary = "Negation operator";
  let description = [{
    The `neg` op takes a single complex number `complex` and returns `-complex`.

    Example:

    ```mlir
    %a = complex.neg %b : complex<f32>
    ```
  }];

  let results = (outs Complex<AnyFloat>:$result);
}

//===----------------------------------------------------------------------===//
// NotEqualOp
//===----------------------------------------------------------------------===//

def NotEqualOp : Complex_Op<"neq",
    [NoSideEffect, AllTypesMatch<["lhs", "rhs"]>, Elementwise]> {
  let summary = "computes whether two complex values are not equal";
  let description = [{
    The `neq` op takes two complex numbers and returns whether they are not
    equal.

    Example:

    ```mlir
    %a = complex.neq %b, %c : complex<f32>
    ```
  }];

  let arguments = (ins Complex<AnyFloat>:$lhs, Complex<AnyFloat>:$rhs);
  let results = (outs I1:$result);
  let builders = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs), [{
      build($_builder, $_state, $_builder.getI1Type(), lhs, rhs);
    }]>];

  let assemblyFormat = "$lhs `,` $rhs  attr-dict `:` type($lhs)";
}

//===----------------------------------------------------------------------===//
// ReOp
//===----------------------------------------------------------------------===//

def ReOp : ComplexUnaryOp<"re",
    [TypesMatchWith<"complex element type matches result type",
                    "complex", "real",
                    "$_self.cast<ComplexType>().getElementType()">]> {
  let summary = "extracts the real part of a complex number";
  let description = [{
    The `re` op takes a single complex number and extracts the real part.

    Example:

    ```mlir
    %a = complex.re %b : complex<f32>
    ```
  }];

  let results = (outs AnyFloat:$real);
  let hasFolder = 1;
}

//===----------------------------------------------------------------------===//
// SignOp
//===----------------------------------------------------------------------===//

def SignOp : ComplexUnaryOp<"sign", [SameOperandsAndResultType]> {
  let summary = "computes sign of a complex number";
  let description = [{
    The `sign` op takes a single complex number and computes the sign of
    it, i.e. `y = sign(x) = x / |x|` if `x != 0`, otherwise `y = 0`.

    Example:

    ```mlir
    %a = complex.sign %b : complex<f32>
    ```
  }];

  let results = (outs Complex<AnyFloat>:$result);
}

//===----------------------------------------------------------------------===//
// SubOp
//===----------------------------------------------------------------------===//

def SubOp : ComplexArithmeticOp<"sub"> {
  let summary = "complex subtraction";
  let description = [{
    The `sub` operation takes two complex numbers and returns their difference.

    Example:

    ```mlir
    %a = complex.sub %b, %c : complex<f32>
    ```
  }];
}

#endif // COMPLEX_OPS
