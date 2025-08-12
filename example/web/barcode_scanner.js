window.startHtml5Qrcode = function(elementId, onSuccess, onError) {
  const html5QrCode = new Html5Qrcode(elementId);
  html5QrCode.start(
    { facingMode: "environment" },
    {
      fps: 10,
      qrbox: 250
    },
    (decodedText, decodedResult) => {
      if (onSuccess) {
        onSuccess(decodedText);
      }
      html5QrCode.stop();
    },
    (errorMessage) => {
      if (onError) {
        onError(errorMessage);
      }
    }
  );
};
