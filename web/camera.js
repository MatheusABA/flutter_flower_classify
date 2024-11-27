function getCameraStream() {
    return navigator.mediaDevices.getUserMedia({ video: true });
  }
  
  function stopCameraStream(stream) {
    const tracks = stream.getTracks();
    tracks.forEach(track => track.stop());
  }
  