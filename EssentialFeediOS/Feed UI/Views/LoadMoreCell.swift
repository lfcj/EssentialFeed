import UIKit

 public class LoadMoreCell: UITableViewCell {

     private lazy var activityIndicator: UIActivityIndicatorView = {
         let spinner = UIActivityIndicatorView(style: .medium)
         contentView.addSubview(spinner)

         spinner.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
         ])

         return spinner
     }()

     public var isLoading: Bool {
         get { activityIndicator.isAnimating }
         set {
             if newValue {
                 activityIndicator.startAnimating()
             } else {
                 activityIndicator.stopAnimating()
             }
         }
     }

 }
