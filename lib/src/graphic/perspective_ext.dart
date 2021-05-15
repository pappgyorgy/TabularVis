part of renderer;

class PerspectiveExt extends Perspective {
  Camera camera;
  double fov = 50.0; // horizontal fov in deg  divided by 2
  double aspect = 1.0;
  double near = 0.1;
  double far = 1000.0;
  Map<String, Object> uniforms = {};
  final Matrix4 perspectiveViewMatrix = new Matrix4.identity();
  final Matrix4 viewMatrix = new Matrix4.identity();
  final Matrix4 mat = new Matrix4.zero();

  PerspectiveExt(this.camera, this.near, this.far,
      [String name = "perspective"])
      : super(camera, near, far, name) {
    Update();
  }

  @override
  void AdjustAspect(int w, int h) {
    double a = w / h;

    if (aspect == a) return;
    aspect = a;
    Update();
  }

  @override
  void Update() {
    setPerspectiveMatrix(mat, fov * PI / 180.0, aspect, near, far);
  }

  void UpdateFov(double fovNew) {
    if (this.fov == fovNew) return;
    this.fov = fovNew;
    Update();
  }

  void UpdateCamera(Camera cam) {
    this.camera = cam;
  }

  void ForceUniformPublic(String canonical, Object val) {
    this.uniforms[canonical] = val;
  }

  Matrix4 get perspectiveMatrix => this.mat;

  Matrix4 get perspectiveMatrixInverse => new Matrix4.identity()..copyInverse(this.mat);

  Vector3 unProjectVector(Vector3 vector){
    Matrix4 inversePerspectiveMatrix = this.perspectiveMatrixInverse;

    this.camera.getViewMatrix(this.viewMatrix);
    this.viewMatrix[12] *= -1;
    this.viewMatrix[13] *= -1;
    this.viewMatrix[14] *= -1;

    Matrix4 inversePerspectiveViewMatrix = this.viewMatrix.multiplied(inversePerspectiveMatrix);

    return vector.clone()..applyProjection(inversePerspectiveViewMatrix);
  }

  @override
  Map<String, Object> GetUniforms() {
    ForceUniformPublic(uEyePosition, this.camera.getEyePosition());
    this.camera.getViewMatrix(this.viewMatrix);
    this.perspectiveViewMatrix.setFrom(this.mat);
    this.perspectiveViewMatrix.multiply(this.viewMatrix);
    ForceUniformPublic(uPerspectiveViewMatrix, this.perspectiveViewMatrix);
    return this.uniforms;
  }
}